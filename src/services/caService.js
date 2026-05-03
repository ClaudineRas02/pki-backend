import path from "path";
import {
  countChildCAs,
  countLinkedCertificates,
  createCA,
  deleteCA,
  findCAById,
  getTrustChain,
  listCAs,
  updateCA,
} from "../models/caModel.js";
import { createHttpError } from "../utils/httpError.js";
import {
  buildSubject,
  createSanConfig,
  extractCommonName,
  getOpenSslKeyArguments,
  readCertificateMetadata,
  runOpenSSL,
} from "../utils/openssl.js";
import {
  createStorageDirectory,
  readFileAsText,
  safeFilename,
  writeBase64File,
  writeTextFile,
} from "../utils/storage.js";
import { getValidityDays } from "../utils/validity.js";

const ROOT_TYPE = "ROOT";
const INTERMEDIATE_TYPE = "INTERMEDIATE";

const assertName = (name) => {
  if (!name || !String(name).trim()) {
    throw createHttpError(400, "Le nom de la CA est obligatoire.");
  }
};

//recup info ca selon id
const assertCAExists = async (caId) => {
  const ca = await findCAById(caId);
  if (!ca) {
    throw createHttpError(404, "CA introuvable.");
  }

  return ca;
};

const assertParentForIntermediate = async (parentCaId) => {
  if (!parentCaId) {
    throw createHttpError(
      400,
      "Une CA intermediaire doit referencer une CA parente.",
    );
  }

  return assertCAExists(parentCaId);
};

const buildCaRecordFromFiles = async ({
  name,
  caType,
  parentCaId = null,
  keyPath = null,
  certPath,
  serialPath = null,
  sourceFormat,
  status = "VALID",
}) => {
  const certificate = await readFileAsText(certPath);
  const privateKey = keyPath ? await readFileAsText(keyPath) : null;
  const metadata = await readCertificateMetadata(certPath);

  return createCA({
    name,
    caType,
    parentCaId,
    privateKey,
    certificate,
    expiresAt: metadata.expiresAt,
    status,
    subjectDn: metadata.subjectDn,
    issuerDn: metadata.issuerDn,
    serialNumber: metadata.serialNumber,
    fingerprintSha256: metadata.fingerprintSha256,
    keyPath,
    certPath,
    serialPath,
    sourceFormat,
  });
};

//crée cert avec openssl command met cert dans dossier /storage/cas et enreg ses infos dans BD
export const createRootCA = async (payload) => {
  assertName(payload.name || payload.common_name);
  const validityDays = getValidityDays(payload.validity_days, 365);
  const subject = buildSubject({
    ...payload,
    common_name: payload.common_name || payload.name,
  });
  const { args: keyArgs } = getOpenSslKeyArguments(payload.algorithm);
  const directory = await createStorageDirectory("cas", "root-ca");
  const baseName = safeFilename(payload.name || payload.common_name, "root-ca");
  const keyPath = path.join(directory, `${baseName}.key`);
  const certPath = path.join(directory, `${baseName}.crt`);
  const serialPath = path.join(directory, `${baseName}.srl`);
  const { configPath } = await createSanConfig({
    commonName: payload.common_name || payload.name,
    extensionType: "v3_ca",
    fileLabel: `${baseName}-root`,
  });

  await runOpenSSL([
    "req",
    "-x509",
    "-new",
    ...keyArgs,
    "-nodes",
    "-keyout",
    keyPath,
    "-out",
    certPath,
    "-days",
    String(validityDays),
    "-subj",
    subject,
    "-config",
    configPath,
    "-extensions",
    "v3_ca",
  ]);

  return buildCaRecordFromFiles({
    name: payload.name || payload.common_name,
    caType: ROOT_TYPE,
    keyPath,
    certPath,
    serialPath,
    sourceFormat: "pem",
  });
};

//différence avec root simple => présence d un cert root racine (parent)
export const createIntermediateCA = async (payload) => {
  assertName(payload.name || payload.common_name);
  const parent = await assertParentForIntermediate(payload.parent_ca_id);
  if (!parent.key_path || !parent.cert_path) {
    throw createHttpError(
      400,
      "La CA parente doit disposer d'une cle et d'un certificat sur disque.",
    );
  }

  const validityDays = getValidityDays(payload.validity_days, 365);
  const subject = buildSubject({
    ...payload,
    common_name: payload.common_name || payload.name,
  });
  const { args: keyArgs } = getOpenSslKeyArguments(payload.algorithm);
  const directory = await createStorageDirectory("cas", "intermediate-ca");
  const baseName = safeFilename(
    payload.name || payload.common_name,
    "intermediate-ca",
  );
  const keyPath = path.join(directory, `${baseName}.key`);
  const csrPath = path.join(directory, `${baseName}.csr`);
  const certPath = path.join(directory, `${baseName}.crt`);
  const serialPath = path.join(directory, `${baseName}.srl`);
  const parentSerialPath =
    parent.serial_path ||
    path.join(
      path.dirname(parent.cert_path),
      `${safeFilename(parent.name, "ca")}.srl`,
    );
  const { configPath } = await createSanConfig({
    commonName: payload.common_name || payload.name,
    extensionType: "v3_intermediate_ca",
    fileLabel: `${baseName}-intermediate`,
  });

  await runOpenSSL([
    "req",
    "-new",
    ...keyArgs,
    "-nodes",
    "-keyout",
    keyPath,
    "-out",
    csrPath,
    "-subj",
    subject,
  ]);

  await runOpenSSL([
    "x509",
    "-req",
    "-in",
    csrPath,
    "-CA",
    parent.cert_path,
    "-CAkey",
    parent.key_path,
    "-CAserial",
    parentSerialPath,
    "-CAcreateserial",
    "-out",
    certPath,
    "-days",
    String(validityDays),
    "-extfile",
    configPath,
    "-extensions",
    "v3_intermediate_ca",
  ]);

  return buildCaRecordFromFiles({
    name: payload.name || payload.common_name,
    caType: INTERMEDIATE_TYPE,
    parentCaId: payload.parent_ca_id,
    keyPath,
    certPath,
    serialPath,
    sourceFormat: "pem",
  });
};

export const importExistingCA = async (payload) => {
  if (!payload) {
    throw createHttpError(
      400,
      "Payload d'import CA absent. Envoie du JSON ou un form-data avec certificate et private_key.",
    );
  }

  const directory = await createStorageDirectory("cas", "imported-ca");
  const baseName = safeFilename(payload.name || "imported-ca", "imported-ca");
  const certPath = path.join(directory, `${baseName}.crt.pem`);
  const keyPath = path.join(directory, `${baseName}.key.pem`);

  if (payload.certificate_base64) {
    await writeBase64File(certPath, payload.certificate_base64);
  } else if (payload.certificate) {
    await writeTextFile(certPath, payload.certificate);
  } else {
    throw createHttpError(
      400,
      "Un fichier certificat .crt/.pem est requis pour importer une CA.",
    );
  }

  if (payload.private_key_base64) {
    await writeBase64File(keyPath, payload.private_key_base64);
  } else if (payload.private_key) {
    await writeTextFile(keyPath, payload.private_key);
  } else {
    throw createHttpError(
      400,
      "Un fichier cle privee .key/.pem est requis pour importer une CA.",
    );
  }

  const metadata = await readCertificateMetadata(certPath);
  const caType =
    payload.ca_type || (payload.parent_ca_id ? INTERMEDIATE_TYPE : ROOT_TYPE);
  const name =
    payload.name || extractCommonName(metadata.subjectDn) || baseName;

  if (payload.parent_ca_id) {
    await assertParentForIntermediate(payload.parent_ca_id);
  }

  return buildCaRecordFromFiles({
    name,
    caType,
    parentCaId: payload.parent_ca_id ?? null,
    keyPath,
    certPath,
    serialPath: path.join(directory, `${baseName}.srl`),
    sourceFormat: "pem",
    status: payload.status || "VALID",
  });
};

export const exportCA = async (caId) => {
  const ca = await assertCAExists(caId);
  return buildCAExportManifest(ca);
};

const assertCAExportable = (ca) => {
  if (!ca.cert_path) {
    throw createHttpError(
      404,
      "Aucun fichier certificat exportable pour cette CA.",
    );
  }
};

const buildCAExportManifest = (ca) => {
  assertCAExportable(ca);

  const files = [
    {
      kind: "certificate",
      filename: `${safeFilename(ca.name, "ca")}.crt.pem`,
      download_path: `/cas/${ca.ca_id}/export/certificate`,
      mime_type: "application/x-pem-file",
    },
  ];

  if (ca.key_path) {
    files.push({
      kind: "private_key",
      filename: `${safeFilename(ca.name, "ca")}.key.pem`,
      download_path: `/cas/${ca.ca_id}/export/private-key`,
      mime_type: "application/x-pem-file",
    });
  }

  return {
    ca_id: ca.ca_id,
    name: ca.name,
    format: "pem",
    files,
  };
};

export const exportCAArtifact = async (caId) => {
  const ca = await assertCAExists(caId);
  return buildCAExportManifest(ca);
};

export const getCAExportFile = async (caId, fileKind) => {
  const ca = await assertCAExists(caId);
  assertCAExportable(ca);

  if (fileKind === "certificate") {
    return {
      filePath: ca.cert_path,
      filename: `${safeFilename(ca.name, "ca")}.crt.pem`,
    };
  }

  if (fileKind === "private-key") {
    if (!ca.key_path) {
      throw createHttpError(404, "Aucune cle privee exportable pour cette CA.");
    }

    return {
      filePath: ca.key_path,
      filename: `${safeFilename(ca.name, "ca")}.key.pem`,
    };
  }

  throw createHttpError(400, "Type de fichier CA export invalide.");
};

export const getCAChain = async (caId) => {
  const chain = await getTrustChain(caId);
  if (!chain.length) {
    throw createHttpError(404, "CA introuvable.");
  }

  return {
    ca_id: Number(caId),
    chain,
  };
};

export const getAllCAs = async () => {
  return listCAs();
};

export const updateExistingCA = async (caId, payload) => {
  const existingCA = await assertCAExists(caId);
  const nextName = payload.name !== undefined ? payload.name : existingCA.name;
  assertName(nextName);

  const nextCaType = payload.ca_type || existingCA.ca_type;
  const nextParentCaId =
    payload.parent_ca_id !== undefined
      ? payload.parent_ca_id
      : existingCA.parent_ca_id;

  if (nextParentCaId === caId) {
    throw createHttpError(400, "Une CA ne peut pas etre sa propre parente.");
  }

  if (nextCaType === ROOT_TYPE && nextParentCaId) {
    throw createHttpError(400, "Une Root CA ne doit pas avoir de parent.");
  }

  if (nextCaType === INTERMEDIATE_TYPE && nextParentCaId) {
    await assertParentForIntermediate(nextParentCaId);
  }

  return updateCA(caId, {
    name: String(nextName).trim(),
    caType: nextCaType,
    parentCaId: nextParentCaId ?? null,
    privateKey:
      payload.private_key !== undefined
        ? payload.private_key
        : existingCA.private_key,
    certificate:
      payload.certificate !== undefined
        ? payload.certificate
        : existingCA.certificate,
    expiresAt: existingCA.expires_at,
    status: payload.status || existingCA.status,
    subjectDn: existingCA.subject_dn,
    issuerDn: existingCA.issuer_dn,
    serialNumber: existingCA.serial_number,
    fingerprintSha256: existingCA.fingerprint_sha256,
    keyPath: existingCA.key_path,
    certPath: existingCA.cert_path,
    serialPath: existingCA.serial_path,
    sourceFormat: existingCA.source_format,
  });
};

export const deleteExistingCA = async (caId) => {
  await assertCAExists(caId);

  const childCAs = await countChildCAs(caId);
  if (childCAs > 0) {
    throw createHttpError(
      409,
      "Suppression impossible: cette CA est parente d'autres certificate authorities.",
    );
  }

  const linkedCertificates = await countLinkedCertificates(caId);
  if (linkedCertificates > 0) {
    throw createHttpError(
      409,
      "Suppression impossible: cette CA est encore liee a des certificats.",
    );
  }

  return deleteCA(caId);
};

import path from "path";
import { findCAById } from "../models/caModel.js";
import {
  createCertificate,
  replaceCertificateSans,
} from "../models/certModel.js";
import {
  createCsr,
  findCsrById,
  listCsrSans,
  listCsrs,
  replaceCsrSans,
  updateCsr,
} from "../models/csrModel.js";
import { createHttpError } from "../utils/httpError.js";
import { normalizeAlgorithmType } from "../utils/algorithm.js";
import {
  buildSubject,
  createSanConfig,
  extractCommonName,
  getOpenSslKeyArguments,
  readCertificateMetadata,
  readCsrMetadata,
  runOpenSSL,
} from "../utils/openssl.js";
import {
  createStorageDirectory,
  readFileAsBase64,
  readFileAsText,
  safeFilename,
  writeBase64File,
  writeTextFile,
} from "../utils/storage.js";
import { getValidityDays } from "../utils/validity.js";

const normalizeSans = (sanList, commonName) => {
  const uniqueSans = Array.from(
    new Set(
      (Array.isArray(sanList) ? sanList : String(sanList || "").split(","))
        .map((entry) => String(entry).trim())
        .filter(Boolean),
    ),
  );

  if (commonName && !uniqueSans.includes(commonName)) {
    uniqueSans.unshift(commonName);
  }

  return uniqueSans;
};

const assertCsrExists = async (csrId) => {
  const csr = await findCsrById(csrId);
  if (!csr) {
    throw createHttpError(404, "CSR introuvable.");
  }

  return csr;
};

const assertCAExists = async (caId) => {
  const ca = await findCAById(caId);
  if (!ca) {
    throw createHttpError(404, "CA introuvable.");
  }

  if (!ca.key_path || !ca.cert_path) {
    throw createHttpError(400, "La CA ne dispose pas des fichiers requis pour signer un CSR.");
  }

  return ca;
};

export const generateCsr = async (payload) => {
  const commonName = payload.common_name;
  if (!commonName) {
    throw createHttpError(400, "Le common_name est obligatoire.");
  }

  const subject = buildSubject(payload);
  const { args: keyArgs, algorithmLabel } = getOpenSslKeyArguments(payload.algorithm);
  const sanList = normalizeSans(payload.san_list, commonName);
  const directory = await createStorageDirectory("csrs", "generated-csr");
  const baseName = safeFilename(commonName, "csr");
  const keyPath = path.join(directory, `${baseName}.key.pem`);
  const csrPath = path.join(directory, `${baseName}.csr.pem`);
  const { configPath, sanList: effectiveSans } = await createSanConfig({
    commonName,
    sanList,
    extensionType: "v3_cert",
    fileLabel: `${baseName}-csr`,
    forRequest: true,
  });

  if (payload.private_key_base64 || payload.private_key) {
    if (payload.private_key_base64) {
      await writeBase64File(keyPath, payload.private_key_base64);
    } else {
      await writeTextFile(keyPath, payload.private_key);
    }

    await runOpenSSL([
      "req",
      "-new",
      "-key",
      keyPath,
      "-out",
      csrPath,
      "-subj",
      subject,
      "-config",
      configPath,
      "-reqexts",
      "v3_cert",
    ]);
  } else {
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
      "-config",
      configPath,
      "-reqexts",
      "v3_cert",
    ]);
  }

  const csrPem = await readFileAsText(csrPath);
  const privateKeyPem = await readFileAsText(keyPath);
  const metadata = await readCsrMetadata(csrPath);
  const csr = await createCsr({
    commonName,
    algorithm: normalizeAlgorithmType(metadata.algorithm || algorithmLabel),
    status: "PENDING",
    subjectDn: metadata.subjectDn,
    csr: csrPem,
    privateKey: privateKeyPem,
    csrPath,
    keyPath,
    sourceFormat: "pem",
  });

  await replaceCsrSans(csr.csr_id, effectiveSans);
  return csr;
};

export const importExistingCsr = async (payload) => {
  if (!payload.csr_base64 && !payload.csr) {
    throw createHttpError(400, "csr_base64 ou csr est requis pour l'import CSR.");
  }

  const directory = await createStorageDirectory("csrs", "imported-csr");
  const baseName = safeFilename(payload.common_name || "imported-csr", "imported-csr");
  const csrPath = path.join(directory, `${baseName}.csr.pem`);

  if (payload.csr_base64) {
    await writeBase64File(csrPath, payload.csr_base64);
  } else {
    await writeTextFile(csrPath, payload.csr);
  }

  const metadata = await readCsrMetadata(csrPath);
  const commonName = payload.common_name || extractCommonName(metadata.subjectDn) || baseName;
  const csrPem = await readFileAsText(csrPath);
  const csr = await createCsr({
    commonName,
    algorithm: normalizeAlgorithmType(metadata.algorithm),
    status: "IMPORTED",
    subjectDn: metadata.subjectDn,
    csr: csrPem,
    csrPath,
    sourceFormat: "pem",
  });

  await replaceCsrSans(csr.csr_id, normalizeSans(payload.san_list || metadata.sanList, commonName));
  return csr;
};

export const signCsrWithCa = async (csrId, payload) => {
  const csr = await assertCsrExists(csrId);
  const ca = await assertCAExists(payload.ca_id);
  const validityDays = getValidityDays(payload.validity_days, 365);
  const sanList = normalizeSans(await listCsrSans(csrId), csr.common_name);
  const directory = await createStorageDirectory("certificates", "signed-from-csr");
  const baseName = safeFilename(csr.common_name, "signed-cert");
  const certPath = path.join(directory, `${baseName}.crt.pem`);
  const parentSerialPath =
    ca.serial_path || path.join(path.dirname(ca.cert_path), `${safeFilename(ca.name, "ca")}.srl`);
  const { configPath, sanList: effectiveSans } = await createSanConfig({
    commonName: csr.common_name,
    sanList,
    extensionType: "v3_cert",
    fileLabel: `${baseName}-signed`,
  });

  await runOpenSSL([
    "x509",
    "-req",
    "-in",
    csr.csr_path,
    "-CA",
    ca.cert_path,
    "-CAkey",
    ca.key_path,
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
    "v3_cert",
  ]);

  const metadata = await readCertificateMetadata(certPath);
  const certificate = await createCertificate({
    commonName: csr.common_name,
    certType: String(payload.cert_type || "SERVER").trim().toUpperCase(),
    algorithm: normalizeAlgorithmType(metadata.algorithm || csr.algorithm),
    expiresAt: metadata.expiresAt,
    status: "VALID",
    caId: ca.ca_id,
    subjectDn: metadata.subjectDn,
    issuerDn: metadata.issuerDn,
    serialNumber: metadata.serialNumber,
    fingerprintSha256: metadata.fingerprintSha256,
    keyPath: csr.key_path,
    certPath,
    sourceFormat: "pem",
    csrId,
  });

  await replaceCertificateSans(certificate.cert_id, effectiveSans);
  await updateCsr(csrId, {
    status: "SIGNED",
    signedCertificateId: certificate.cert_id,
    caId: ca.ca_id,
  });

  return {
    csr_id: csrId,
    certificate_id: certificate.cert_id,
    cert_path: certPath,
  };
};

export const getAllCsrs = async () => {
  const csrs = await listCsrs();
  return Promise.all(
    csrs.map(async (csr) => ({
      ...csr,
      sans: await listCsrSans(csr.csr_id),
    })),
  );
};

export const exportCsr = async (csrId) => {
  const csr = await assertCsrExists(csrId);

  if (!csr.csr_path) {
    throw createHttpError(404, "Aucun fichier CSR exportable pour cette entree.");
  }

  const files = [
    {
      kind: "csr",
      filename: `${safeFilename(csr.common_name, "csr")}.csr.pem`,
      content_base64: await readFileAsBase64(csr.csr_path),
      mime_type: "application/x-pem-file",
    },
  ];

  if (csr.key_path) {
    files.push({
      kind: "private_key",
      filename: `${safeFilename(csr.common_name, "csr")}.key.pem`,
      content_base64: await readFileAsBase64(csr.key_path),
      mime_type: "application/x-pem-file",
    });
  }

  return {
    csr_id: csr.csr_id,
    format: "pem",
    files,
  };
};

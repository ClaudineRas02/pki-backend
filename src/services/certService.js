import path from "path";
import { findCAById } from "../models/caModel.js";
import {
  createCertificate,
  deleteCertificate,
  findCertificateById,
  listCertificateSans,
  listCertificates,
  replaceCertificateSans,
  updateCertificate,
  updateCertificateCA,
} from "../models/certModel.js";
import {
  getAllowedExportFormat,
  getAllowedImportFormat,
  computeValidity,
} from "../utils/certificateFormats.js";
import { createHttpError } from "../utils/httpError.js";
import { normalizeAlgorithmType } from "../utils/algorithm.js";
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
  readFileAsBase64,
  readFileAsText,
  safeFilename,
  writeBase64File,
  writeTextFile,
} from "../utils/storage.js";
import { calculateExpiresAt, getValidityDays } from "../utils/validity.js";

const assertCommonName = (commonName) => {
  if (!commonName || !String(commonName).trim()) {
    throw createHttpError(400, "Le common_name est obligatoire.");
  }
};

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

const assertCertificateExists = async (certId) => {
  const certificate = await findCertificateById(certId);

  if (!certificate) {
    throw createHttpError(404, "Certificat introuvable.");
  }

  return certificate;
};

const assertCAExists = async (caId) => {
  const ca = await findCAById(caId);

  if (!ca) {
    throw createHttpError(404, "CA introuvable.");
  }

  if (!ca.key_path || !ca.cert_path) {
    throw createHttpError(400, "La CA selectionnee ne dispose pas des fichiers necessaires a la signature.");
  }

  return ca;
};

const createCertificateRecordFromFiles = async ({
  commonName,
  certType,
  caId,
  keyPath = null,
  certPath,
  sourceFormat,
  csrId = null,
  sanList = [],
  status = "VALID",
}) => {
  const certificatePem = await readFileAsText(certPath);
  const privateKeyPem = keyPath ? await readFileAsText(keyPath) : null;
  const metadata = await readCertificateMetadata(certPath);
  const certificate = await createCertificate({
    commonName,
    certType,
    algorithm: normalizeAlgorithmType(metadata.algorithm),
    expiresAt: metadata.expiresAt,
    status,
    caId,
    subjectDn: metadata.subjectDn,
    issuerDn: metadata.issuerDn,
    serialNumber: metadata.serialNumber,
    fingerprintSha256: metadata.fingerprintSha256,
    keyPath,
    certPath,
    sourceFormat,
    csrId,
  });

  await replaceCertificateSans(
    certificate.cert_id,
    sanList.length ? sanList : metadata.sanList,
  );

  return {
    ...certificate,
    certificate: certificatePem,
    private_key: privateKeyPem,
  };
};

const formatCertificateDetails = async (certificate) => {
  const sans = await listCertificateSans(certificate.cert_id);

  return {
    cert_id: certificate.cert_id,
    common_name: certificate.common_name,
    cert_type: certificate.cert_type,
    algorithm: certificate.algorithm,
    status: certificate.status,
    subject_dn: certificate.subject_dn,
    issuer_dn: certificate.issuer_dn,
    fingerprint_sha256: certificate.fingerprint_sha256,
    ca: certificate.ca_id
      ? {
          ca_id: certificate.ca_id,
          name: certificate.ca_name,
          ca_type: certificate.ca_type,
        }
      : null,
    sans,
    validity: computeValidity(certificate.issued_at, certificate.expires_at),
  };
};

export const generateCertificate = async (payload) => {
  assertCommonName(payload.common_name);
  const ca = await assertCAExists(payload.ca_id);
  const validityDays = getValidityDays(payload.validity_days, 365);
  const sanList = normalizeSans(payload.san_list, payload.common_name);
  const subject = buildSubject(payload);
  const { args: keyArgs } = getOpenSslKeyArguments(payload.algorithm);
  const directory = await createStorageDirectory("certificates", "generated-cert");
  const baseName = safeFilename(payload.common_name, "certificate");
  const keyPath = path.join(directory, `${baseName}.key.pem`);
  const csrPath = path.join(directory, `${baseName}.csr.pem`);
  const certPath = path.join(directory, `${baseName}.crt.pem`);
  const parentSerialPath =
    ca.serial_path || path.join(path.dirname(ca.cert_path), `${safeFilename(ca.name, "ca")}.srl`);
  const { configPath, sanList: effectiveSans } = await createSanConfig({
    commonName: payload.common_name,
    sanList,
    extensionType: "v3_cert",
    fileLabel: `${baseName}-cert`,
    forRequest: true,
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
    "-config",
    configPath,
    "-reqexts",
    "v3_cert",
  ]);

  await runOpenSSL([
    "x509",
    "-req",
    "-in",
    csrPath,
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

  return createCertificateRecordFromFiles({
    commonName: payload.common_name.trim(),
    certType: String(payload.cert_type || "SERVER").trim().toUpperCase(),
    caId: payload.ca_id,
    keyPath,
    certPath,
    sourceFormat: "pem",
    sanList: effectiveSans,
  });
};

export const signCertificate = async (certId, payload) => {
  await assertCertificateExists(certId);
  await assertCAExists(payload.ca_id);

  const signedCertificate = await updateCertificateCA(certId, payload.ca_id);
  return signedCertificate;
};

export const importExistingCertificate = async (payload) => {
  const format = getAllowedImportFormat(payload.file_format, createHttpError);
  const commonNameFallback = payload.common_name || "imported-certificate";
  const directory = await createStorageDirectory("certificates", "imported-cert");
  const baseName = safeFilename(commonNameFallback, "imported-certificate");
  let certPath = path.join(directory, `${baseName}.crt.pem`);
  let keyPath = null;

  if (format === "p12") {
    if (!payload.bundle_base64) {
      throw createHttpError(400, "bundle_base64 est requis pour importer un certificat p12.");
    }

    const p12Path = path.join(directory, `${baseName}.p12`);
    keyPath = path.join(directory, `${baseName}.key.pem`);
    await writeBase64File(p12Path, payload.bundle_base64);

    await runOpenSSL([
      "pkcs12",
      "-in",
      p12Path,
      "-clcerts",
      "-nokeys",
      "-out",
      certPath,
      "-passin",
      `pass:${payload.passphrase || ""}`,
    ]);

    await runOpenSSL([
      "pkcs12",
      "-in",
      p12Path,
      "-nocerts",
      "-nodes",
      "-out",
      keyPath,
      "-passin",
      `pass:${payload.passphrase || ""}`,
    ]);
  } else {
    if (payload.certificate_base64) {
      await writeBase64File(certPath, payload.certificate_base64);
    } else if (payload.certificate) {
      await writeTextFile(certPath, payload.certificate);
    } else {
      throw createHttpError(400, "certificate_base64 ou certificate est requis pour l'import.");
    }

    if (payload.private_key_base64 || payload.private_key) {
      keyPath = path.join(directory, `${baseName}.key.pem`);
      if (payload.private_key_base64) {
        await writeBase64File(keyPath, payload.private_key_base64);
      } else {
        await writeTextFile(keyPath, payload.private_key);
      }
    }
  }

  const metadata = await readCertificateMetadata(certPath);
  const commonName = payload.common_name || extractCommonName(metadata.subjectDn) || baseName;
  const sanList = normalizeSans(payload.san_list || metadata.sanList, commonName);
  const caId = payload.ca_id ?? null;

  if (caId) {
    await assertCAExists(caId);
  }

  return createCertificateRecordFromFiles({
    commonName,
    certType: String(payload.cert_type || "SERVER").trim().toUpperCase(),
    caId,
    keyPath,
    certPath,
    sourceFormat: format,
    sanList,
    status: payload.status ? String(payload.status).trim().toUpperCase() : "VALID",
  });
};

export const exportCertificate = async (certId, format, passphrase = "") => {
  const certificate = await assertCertificateExists(certId);
  const exportFormat = getAllowedExportFormat(format, createHttpError);

  if (!certificate.cert_path) {
    throw createHttpError(404, "Aucun fichier certificat exportable pour cette entree.");
  }

  if (exportFormat === "p12") {
    if (!certificate.key_path) {
      throw createHttpError(400, "L'export P12 requiert la cle privee du certificat.");
    }

    const directory = await createStorageDirectory("exports", "cert-p12");
    const bundlePath = path.join(
      directory,
      `${safeFilename(certificate.common_name, "certificate")}.p12`,
    );
    const extraArgs = [];

    if (certificate.ca_id) {
      const ca = await findCAById(certificate.ca_id);
      if (ca?.cert_path) {
        extraArgs.push("-certfile", ca.cert_path);
      }
    }

    await runOpenSSL([
      "pkcs12",
      "-export",
      "-inkey",
      certificate.key_path,
      "-in",
      certificate.cert_path,
      ...extraArgs,
      "-out",
      bundlePath,
      "-passout",
      `pass:${passphrase || ""}`,
      "-name",
      certificate.common_name,
    ]);

    return {
      cert_id: certificate.cert_id,
      format: "p12",
      files: [
        {
          kind: "bundle",
          filename: `${safeFilename(certificate.common_name, "certificate")}.p12`,
          content_base64: await readFileAsBase64(bundlePath),
          mime_type: "application/x-pkcs12",
        },
      ],
    };
  }

  const files = [
    {
      kind: "certificate",
      filename: `${safeFilename(certificate.common_name, "certificate")}.crt.pem`,
      content_base64: await readFileAsBase64(certificate.cert_path),
      mime_type: "application/x-pem-file",
    },
  ];

  if (certificate.key_path) {
    files.push({
      kind: "private_key",
      filename: `${safeFilename(certificate.common_name, "certificate")}.key.pem`,
      content_base64: await readFileAsBase64(certificate.key_path),
      mime_type: "application/x-pem-file",
    });
  }

  return {
    cert_id: certificate.cert_id,
    format: exportFormat,
    files,
  };
};

export const getCertificateDetails = async (certId) => {
  const certificate = await assertCertificateExists(certId);
  return formatCertificateDetails(certificate);
};

export const getAllCertificates = async () => {
  const certificates = await listCertificates();
  return Promise.all(
    certificates.map(async (certificate) => ({
      ...certificate,
      sans: await listCertificateSans(certificate.cert_id),
    })),
  );
};

export const updateExistingCertificate = async (certId, payload) => {
  const existingCertificate = await assertCertificateExists(certId);
  const nextCommonName =
    payload.common_name !== undefined
      ? payload.common_name
      : existingCertificate.common_name;
  assertCommonName(nextCommonName);

  const nextCaId =
    payload.ca_id !== undefined ? payload.ca_id : existingCertificate.ca_id;

  if (nextCaId !== null && nextCaId !== undefined) {
    await assertCAExists(nextCaId);
  }

  const validityDays = getValidityDays(payload.validity_days);
  return updateCertificate(certId, {
    commonName: String(nextCommonName).trim(),
    certType:
      payload.cert_type !== undefined
        ? String(payload.cert_type).trim().toUpperCase()
        : existingCertificate.cert_type,
    algorithm:
      payload.algorithm !== undefined
        ? normalizeAlgorithmType(payload.algorithm)
        : existingCertificate.algorithm,
    expiresAt:
      validityDays !== null
        ? calculateExpiresAt(validityDays, existingCertificate.issued_at)
        : existingCertificate.expires_at,
    status:
      payload.status !== undefined
        ? String(payload.status).trim().toUpperCase()
        : existingCertificate.status,
    caId: nextCaId ?? null,
    subjectDn: existingCertificate.subject_dn,
    issuerDn: existingCertificate.issuer_dn,
    serialNumber: existingCertificate.serial_number,
    fingerprintSha256: existingCertificate.fingerprint_sha256,
    keyPath: existingCertificate.key_path,
    certPath: existingCertificate.cert_path,
    sourceFormat: existingCertificate.source_format,
    csrId: existingCertificate.csr_id,
  });
};

export const deleteExistingCertificate = async (certId) => {
  await assertCertificateExists(certId);
  return deleteCertificate(certId);
};

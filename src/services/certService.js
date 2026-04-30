import { findCAById } from "../models/caModel.js";
import {
  createCertificate,
  findCertificateById,
  listCertificates,
  updateCertificateCA,
} from "../models/certModel.js";
import {
  getAllowedExportFormat,
  getAllowedImportFormat,
  computeValidity,
} from "../utils/certificateFormats.js";
import { createHttpError } from "../utils/httpError.js";

const formatCertificateDetails = (certificate) => {
  return {
    cert_id: certificate.cert_id,
    common_name: certificate.common_name,
    cert_type: certificate.cert_type,
    algorithm: certificate.algorithm,
    status: certificate.status,
    ca: certificate.ca_id
      ? {
          ca_id: certificate.ca_id,
          name: certificate.ca_name,
          ca_type: certificate.ca_type,
        }
      : null,
    sans: [],
    validity: computeValidity(certificate.issued_at, certificate.expires_at),
  };
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

  return ca;
};

export const generateCertificate = async (payload) => {
  if (payload.ca_id !== undefined && payload.ca_id !== null) {
    await assertCAExists(payload.ca_id);
  }

  return createCertificate({
    commonName: payload.common_name.trim(),
    certType: String(payload.cert_type).trim().toUpperCase(),
    algorithm: String(payload.algorithm).trim().toUpperCase(),
    expiresAt: payload.expires_at || null,
    status: payload.status ? String(payload.status).trim().toUpperCase() : "VALID",
    caId: payload.ca_id ?? null,
  });
};

export const signCertificate = async (certId, payload) => {
  await assertCertificateExists(certId);
  await assertCAExists(payload.ca_id);

  const signedCertificate = await updateCertificateCA(certId, payload.ca_id);
  return signedCertificate;
};

export const importExistingCertificate = async (payload) => {
  const fileFormat = getAllowedImportFormat(payload.file_format, createHttpError);

  if (payload.ca_id !== undefined && payload.ca_id !== null) {
    await assertCAExists(payload.ca_id);
  }

  const certificate = await createCertificate({
    commonName: payload.common_name.trim(),
    certType: String(payload.cert_type).trim().toUpperCase(),
    algorithm: String(payload.algorithm).trim().toUpperCase(),
    expiresAt: payload.expires_at || null,
    status: payload.status ? String(payload.status).trim().toUpperCase() : "VALID",
    caId: payload.ca_id ?? null,
  });

  return {
    ...certificate,
    imported_format: fileFormat,
  };
};

export const exportCertificate = async (certId, format) => {
  const certificate = await assertCertificateExists(certId);
  const exportFormat = getAllowedExportFormat(format, createHttpError);

  return {
    format: exportFormat,
    certificate,
  };
};

export const getCertificateDetails = async (certId) => {
  const certificate = await assertCertificateExists(certId);
  return formatCertificateDetails(certificate);
};

export const getAllCertificates = async () => {
  return listCertificates();
};

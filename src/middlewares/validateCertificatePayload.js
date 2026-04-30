import { createHttpError } from "../utils/httpError.js";

const ALLOWED_CERT_TYPES = ["SERVER", "CLIENT", "WILDCARD"];
const ALLOWED_STATUSES = ["VALID", "EXPIRED", "REVOKED"];

const validateRequiredCertificateFields = (body, { requireCaId = false } = {}) => {
  if (!body.common_name || !String(body.common_name).trim()) {
    throw createHttpError(400, "Le common_name est obligatoire.");
  }

  if (!body.cert_type) {
    throw createHttpError(400, "Le cert_type est obligatoire.");
  }

  if (!body.algorithm) {
    throw createHttpError(400, "L'algorithm est obligatoire.");
  }

  if (!ALLOWED_CERT_TYPES.includes(String(body.cert_type).trim().toUpperCase())) {
    throw createHttpError(
      400,
      `cert_type invalide. Valeurs attendues: ${ALLOWED_CERT_TYPES.join(", ")}.`,
    );
  }

  if (body.status && !ALLOWED_STATUSES.includes(String(body.status).trim().toUpperCase())) {
    throw createHttpError(
      400,
      `status invalide. Valeurs attendues: ${ALLOWED_STATUSES.join(", ")}.`,
    );
  }

  if (requireCaId) {
    const caId = Number(body.ca_id);
    if (!Number.isInteger(caId) || caId <= 0) {
      throw createHttpError(400, "Un ca_id valide est obligatoire.");
    }
  }
};

export const validateCertificateCreation = (req, _res, next) => {
  try {
    validateRequiredCertificateFields(req.body);
    next();
  } catch (error) {
    next(error);
  }
};

export const validateCertificateSigning = (req, _res, next) => {
  try {
    const caId = Number(req.body.ca_id);

    if (!Number.isInteger(caId) || caId <= 0) {
      throw createHttpError(400, "Un ca_id valide est obligatoire pour signer un certificat.");
    }

    next();
  } catch (error) {
    next(error);
  }
};

export const validateCertificateImport = (req, _res, next) => {
  try {
    validateRequiredCertificateFields(req.body);

    if (!req.body.file_format) {
      throw createHttpError(400, "Le file_format est obligatoire pour l'import.");
    }

    next();
  } catch (error) {
    next(error);
  }
};

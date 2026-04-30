const SUPPORTED_IMPORT_FORMATS = ["pem", "crt", "p12"];
const SUPPORTED_EXPORT_FORMATS = ["pem", "crt", "p12"];

const isEmptyFormat = (format) => {
  return format === undefined || format === null || String(format).trim() === "";
};

export const cleanFileFormat = (format) => {
  if (isEmptyFormat(format)) {
    return null;
  }

  return String(format).trim().toLowerCase().replace(/^\./, "");
};

export const getAllowedImportFormat = (format, createHttpError) => {
  const cleanFormat = cleanFileFormat(format);

  if (!SUPPORTED_IMPORT_FORMATS.includes(cleanFormat)) {
    throw createHttpError(
      400,
      `Format d'import non supporte. Formats acceptes: ${SUPPORTED_IMPORT_FORMATS.join(", ")}.`,
    );
  }

  return cleanFormat;
};

export const getAllowedExportFormat = (format, createHttpError) => {
  const cleanFormat = cleanFileFormat(format) || "pem";

  if (!SUPPORTED_EXPORT_FORMATS.includes(cleanFormat)) {
    throw createHttpError(
      400,
      `Format d'export non supporte. Formats acceptes: ${SUPPORTED_EXPORT_FORMATS.join(", ")}.`,
    );
  }

  return cleanFormat;
};

export const computeValidity = (issuedAt, expiresAt) => {
  const now = Date.now();
  const issuedAtMs = issuedAt ? new Date(issuedAt).getTime() : null;
  const expiresAtMs = expiresAt ? new Date(expiresAt).getTime() : null;

  return {
    issued_at: issuedAt,
    expires_at: expiresAt,
    is_active:
      issuedAtMs !== null &&
      expiresAtMs !== null &&
      issuedAtMs <= now &&
      expiresAtMs >= now,
  };
};

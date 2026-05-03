import { createHttpError } from "./httpError.js";

export const getValidityDays = (value, fallbackValue = null) => {
  const sourceValue = value !== undefined ? value : fallbackValue;

  if (sourceValue === undefined || sourceValue === null || sourceValue === "") {
    return null;
  }

  const validityDays = Number(sourceValue);

  if (!Number.isInteger(validityDays) || validityDays <= 0) {
    throw createHttpError(400, "validity_days doit etre un entier positif.");
  }

  return validityDays;
};

export const calculateExpiresAt = (validityDays, baseDate = new Date()) => {
  if (validityDays === null || validityDays === undefined) {
    return null;
  }

  const expiresAt = new Date(baseDate);
  expiresAt.setDate(expiresAt.getDate() + validityDays);
  return expiresAt.toISOString();
};

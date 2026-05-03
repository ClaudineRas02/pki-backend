export const normalizeAlgorithmType = (value, fallback = "RSA_2048") => {
  const source = String(value || fallback).trim().toUpperCase();

  if (source.includes("ECDSA")) {
    return "ECDSA";
  }

  if (source.includes("4096")) {
    return "RSA_4096";
  }

  if (source.includes("RSA")) {
    return "RSA_2048";
  }

  return fallback;
};

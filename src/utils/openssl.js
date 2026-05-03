import path from "path";
import { execFile } from "child_process";
import { promisify } from "util";
import { createHttpError } from "./httpError.js";
import {
  createStorageDirectory,
  safeFilename,
  writeTextFile,
} from "./storage.js";

const execFileAsync = promisify(execFile);

const parseOpenSslDate = (line) => {
  const raw = line.split("=").slice(1).join("=").trim();
  const parsed = new Date(raw);
  return Number.isNaN(parsed.getTime()) ? null : parsed.toISOString();
};

const extractTextValue = (line) => {
  return line.split("=").slice(1).join("=").trim();
};

export const runOpenSSL = async (args) => {
  try {
    const { stdout, stderr } = await execFileAsync("openssl", args);
    return { stdout, stderr };
  } catch (error) {
    throw createHttpError(
      400,
      error.stderr?.trim() || error.message || "La commande openssl a echoue.",
    );
  }
};

export const buildSubject = (payload) => {
  const pairs = [
    ["C", payload.country],
    ["ST", payload.state],
    ["L", payload.locality],
    ["O", payload.organization],
    ["OU", payload.organizational_unit],
    ["CN", payload.common_name || payload.name],
    ["emailAddress", payload.email_address],
  ].filter(([, value]) => value);

  if (!pairs.length) {
    throw createHttpError(
      400,
      "Impossible de construire le sujet openssl sans donnees identitaires.",
    );
  }

  return `/${pairs
    .map(([key, value]) => `${key}=${String(value).replace(/\//g, "\\/")}`)
    .join("/")}`;
};

//crée fichier cnf dans /storage/tmp
export const createSanConfig = async ({
  commonName,
  sanList = [],
  extensionType,
  fileLabel,
  forRequest = false,
}) => {
  const uniqueSans = Array.from(
    new Set(sanList.map((entry) => String(entry).trim()).filter(Boolean)),
  );

  if (commonName && !uniqueSans.includes(commonName)) {
    uniqueSans.unshift(commonName);
  }

  const configLines = [
    "[ req ]",
    "distinguished_name = req_distinguished_name",
  ];

  if (extensionType) {
    configLines.push(`req_extensions = ${extensionType}`);
  }

  configLines.push("", "[ req_distinguished_name ]");

  if (extensionType) {
    configLines.push("", `[ ${extensionType} ]`);
    configLines.push("subjectKeyIdentifier = hash");

    if (!forRequest) {
      configLines.push("authorityKeyIdentifier = keyid,issuer");
    }

    if (extensionType === "v3_ca") {
      configLines.push("basicConstraints = critical, CA:true");
      configLines.push(
        "keyUsage = critical, digitalSignature, cRLSign, keyCertSign",
      );
    }

    if (extensionType === "v3_intermediate_ca") {
      configLines.push("basicConstraints = critical, CA:true, pathlen:0");
      configLines.push(
        "keyUsage = critical, digitalSignature, cRLSign, keyCertSign",
      );
    }

    if (extensionType === "v3_cert") {
      configLines.push("basicConstraints = CA:false");
      configLines.push(
        "keyUsage = critical, digitalSignature, keyEncipherment",
      );
      configLines.push("extendedKeyUsage = serverAuth, clientAuth");
    }

    if (uniqueSans.length) {
      configLines.push("subjectAltName = @alt_names");
      configLines.push("", "[ alt_names ]");
      uniqueSans.forEach((san, index) => {
        configLines.push(`DNS.${index + 1} = ${san}`);
      });
    }
  }

  const tempDir = await createStorageDirectory("tmp", "openssl");
  const configPath = path.join(
    tempDir,
    `${safeFilename(fileLabel, "openssl")}.cnf`,
  );
  //ecris dans storage/tmp/openssl-.../---.cnf
  await writeTextFile(configPath, configLines.join("\n"));

  return {
    configPath,
    sanList: uniqueSans,
  };
};

export const readCertificateMetadata = async (certificatePath) => {
  const details = await runOpenSSL([
    "x509",
    "-in",
    certificatePath,
    "-noout",
    "-subject",
    "-issuer",
    "-enddate",
    "-serial",
    "-fingerprint",
    "-sha256",
    "-text",
  ]);

  const lines = details.stdout.split("\n").map((line) => line.trim());
  const subjectLine = lines.find((line) => line.startsWith("subject="));
  const issuerLine = lines.find((line) => line.startsWith("issuer="));
  const endDateLine = lines.find((line) => line.startsWith("notAfter="));
  const serialLine = lines.find((line) => line.startsWith("serial="));
  const fingerprintLine = lines.find((line) =>
    line.startsWith("sha256 fingerprint="),
  );
  const algorithmLine = lines.find((line) =>
    line.startsWith("Signature Algorithm:"),
  );

  const sanMatches = Array.from(details.stdout.matchAll(/DNS:([^,\n]+)/g)).map(
    (match) => match[1].trim(),
  );

  return {
    subjectDn: subjectLine ? extractTextValue(subjectLine) : null,
    issuerDn: issuerLine ? extractTextValue(issuerLine) : null,
    expiresAt: endDateLine ? parseOpenSslDate(endDateLine) : null,
    serialNumber: serialLine ? extractTextValue(serialLine) : null,
    fingerprintSha256: fingerprintLine
      ? extractTextValue(fingerprintLine)
      : null,
    algorithm: algorithmLine
      ? algorithmLine.replace("Signature Algorithm:", "").trim()
      : null,
    sanList: Array.from(new Set(sanMatches)),
  };
};

export const readCsrMetadata = async (csrPath) => {
  const details = await runOpenSSL([
    "req",
    "-in",
    csrPath,
    "-noout",
    "-subject",
    "-text",
  ]);
  const lines = details.stdout.split("\n").map((line) => line.trim());
  const subjectLine = lines.find((line) => line.startsWith("subject="));
  const algorithmLine = lines.find((line) =>
    line.startsWith("Public Key Algorithm:"),
  );
  const sanMatches = Array.from(details.stdout.matchAll(/DNS:([^,\n]+)/g)).map(
    (match) => match[1].trim(),
  );

  return {
    subjectDn: subjectLine ? extractTextValue(subjectLine) : null,
    algorithm: algorithmLine
      ? algorithmLine.replace("Public Key Algorithm:", "").trim()
      : null,
    sanList: Array.from(new Set(sanMatches)),
  };
};

export const extractCommonName = (subjectDn) => {
  if (!subjectDn) {
    return null;
  }

  const match = subjectDn.match(/CN\s*=\s*([^,]+)/i);
  return match ? match[1].trim() : null;
};

export const getOpenSslKeyArguments = (algorithm) => {
  const normalized = String(algorithm || "RSA-2048")
    .trim()
    .toUpperCase();

  if (normalized.startsWith("RSA")) {
    const sizeMatch = normalized.match(/(\d{4})/);
    const keySize = sizeMatch ? sizeMatch[1] : "2048";
    return {
      algorithmLabel: `RSA ${keySize}`,
      args: ["-newkey", `rsa:${keySize}`],
    };
  }

  throw createHttpError(
    400,
    `Algorithme non supporte pour la generation OpenSSL: ${algorithm}.`,
  );
};

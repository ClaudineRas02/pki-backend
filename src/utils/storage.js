import { promises as fs } from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

//dossier pour stocker les certs
export const STORAGE_ROOT = path.resolve(__dirname, "../../storage");
//genere suffixe pour nom diff des certs
const randomSuffix = () => {
  return `${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;
};

//assure l existence du dir
export const ensureDirectory = async (directoryPath) => {
  await fs.mkdir(directoryPath, { recursive: true });
  return directoryPath;
};

// crée le nom directory et assure sa création
export const createStorageDirectory = async (namespace, prefix) => {
  const directoryPath = path.join(
    STORAGE_ROOT,
    namespace,
    `${prefix}-${randomSuffix()}`,
  );
  return ensureDirectory(directoryPath);
};

export const writeTextFile = async (filePath, content) => {
  await ensureDirectory(path.dirname(filePath));
  await fs.writeFile(filePath, content, "utf8");
  return filePath;
};

export const writeBase64File = async (filePath, base64Content) => {
  await ensureDirectory(path.dirname(filePath));
  await fs.writeFile(filePath, Buffer.from(base64Content, "base64"));
  return filePath;
};

export const readFileAsBase64 = async (filePath) => {
  const buffer = await fs.readFile(filePath);
  return buffer.toString("base64");
};

export const readFileAsText = async (filePath) => {
  return fs.readFile(filePath, "utf8");
};

export const safeFilename = (value, fallback = "artifact") => {
  const source = value || fallback;
  return String(source)
    .trim()
    .replace(/[^a-zA-Z0-9._-]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .toLowerCase();
};

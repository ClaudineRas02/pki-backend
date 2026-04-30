import {
  createCA,
  findCAById,
  getTrustChain,
  listCAs,
} from "../models/caModel.js";

const ROOT_TYPE = "ROOT";
const INTERMEDIATE_TYPE = "INTERMEDIATE";

const createHttpError = (status, message) => {
  const error = new Error(message);
  error.status = status;
  return error;
};

//test if empty name
const assertName = (name) => {
  if (!name || !String(name).trim()) {
    throw createHttpError(400, "Le nom de la CA est obligatoire.");
  }
};

const assertParentForIntermediate = async (parentCaId) => {
  if (!parentCaId) {
    throw createHttpError(
      400,
      "Une CA intermédiaire doit référencer une CA parente.",
    );
  }

  const parent = await findCAById(parentCaId);
  if (!parent) {
    throw createHttpError(404, "La CA parente est introuvable.");
  }

  return parent;
};

// payload = ca info
export const createRootCA = async (payload) => {
  assertName(payload.name);

  return await createCA({
    name: payload.name.trim(),
    caType: payload.ca_type || ROOT_TYPE,
    privateKey: payload.private_key || null,
    certificate: payload.certificate || null,
    expiresAt: payload.expires_at || null,
    status: payload.status || "VALID",
  });
};

export const createIntermediateCA = async (payload) => {
  assertName(payload.name);
  await assertParentForIntermediate(payload.parent_ca_id);

  return await createCA({
    name: payload.name.trim(),
    caType: payload.ca_type || INTERMEDIATE_TYPE,
    parentCaId: payload.parent_ca_id,
    privateKey: payload.private_key || null,
    certificate: payload.certificate || null,
    expiresAt: payload.expires_at || null,
    status: payload.status || "VALID",
  });
};

export const importExistingCA = async (payload) => {
  assertName(payload.name);

  const hasParent =
    payload.parent_ca_id !== undefined && payload.parent_ca_id !== null;
  if (hasParent) {
    await assertParentForIntermediate(payload.parent_ca_id);
  }

  return await createCA({
    name: payload.name.trim(),
    caType: payload.ca_type || (hasParent ? INTERMEDIATE_TYPE : ROOT_TYPE),
    parentCaId: payload.parent_ca_id ?? null,
    privateKey: payload.private_key || null,
    certificate: payload.certificate || null,
    expiresAt: payload.expires_at || null,
    status: payload.status || "VALID",
  });
};

export const exportCA = async (caId) => {
  const ca = await findCAById(caId);
  if (!ca) {
    throw createHttpError(404, "CA introuvable.");
  }

  return ca;
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

import {
  countChildCAs,
  countLinkedCertificates,
  createCA,
  deleteCA,
  findCAById,
  getTrustChain,
  listCAs,
  updateCA,
} from "../models/caModel.js";
import { createHttpError } from "../utils/httpError.js";

const ROOT_TYPE = "ROOT";
const INTERMEDIATE_TYPE = "INTERMEDIATE";

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

const assertCAExists = async (caId) => {
  const ca = await findCAById(caId);
  if (!ca) {
    throw createHttpError(404, "CA introuvable.");
  }

  return ca;
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
  return assertCAExists(caId);
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

export const updateExistingCA = async (caId, payload) => {
  const existingCA = await assertCAExists(caId);

  const nextName = payload.name !== undefined ? payload.name : existingCA.name;
  assertName(nextName);

  const nextCaType = payload.ca_type || existingCA.ca_type;
  const nextParentCaId =
    payload.parent_ca_id !== undefined ? payload.parent_ca_id : existingCA.parent_ca_id;

  if (nextParentCaId === caId) {
    throw createHttpError(400, "Une CA ne peut pas etre sa propre parente.");
  }

  if (nextCaType === ROOT_TYPE && nextParentCaId) {
    throw createHttpError(400, "Une Root CA ne doit pas avoir de parent.");
  }

  if (nextCaType === INTERMEDIATE_TYPE) {
    await assertParentForIntermediate(nextParentCaId);
  }

  return updateCA(caId, {
    name: String(nextName).trim(),
    caType: nextCaType,
    parentCaId: nextParentCaId ?? null,
    privateKey:
      payload.private_key !== undefined ? payload.private_key : existingCA.private_key,
    certificate:
      payload.certificate !== undefined ? payload.certificate : existingCA.certificate,
    expiresAt:
      payload.expires_at !== undefined ? payload.expires_at : existingCA.expires_at,
    status: payload.status || existingCA.status,
  });
};

export const deleteExistingCA = async (caId) => {
  await assertCAExists(caId);

  const childCAs = await countChildCAs(caId);
  if (childCAs > 0) {
    throw createHttpError(
      409,
      "Suppression impossible: cette CA est parente d'autres certificate authorities.",
    );
  }

  const linkedCertificates = await countLinkedCertificates(caId);
  if (linkedCertificates > 0) {
    throw createHttpError(
      409,
      "Suppression impossible: cette CA est encore liee a des certificats.",
    );
  }

  return deleteCA(caId);
};

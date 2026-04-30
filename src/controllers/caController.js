import { handleError } from "../utils/handleError.js";

import {
  createIntermediateCA,
  createRootCA,
  deleteExistingCA,
  exportCA,
  getAllCAs,
  getCAChain,
  importExistingCA,
  updateExistingCA,
} from "../services/caService.js";

export const listCAsController = async (_req, res) => {
  try {
    const cas = await getAllCAs();
    res.status(200).json(cas);
  } catch (error) {
    handleError(error, res);
  }
};

export const createRootCAController = async (req, res) => {
  try {
    const ca = await createRootCA(req.body);
    res.status(201).json(ca);
  } catch (error) {
    handleError(error, res);
  }
};

export const createIntermediateCAController = async (req, res) => {
  try {
    const ca = await createIntermediateCA(req.body);
    res.status(201).json(ca);
  } catch (error) {
    handleError(error, res);
  }
};

export const getTrustChainController = async (req, res) => {
  try {
    const chain = await getCAChain(req.params.caId);
    res.status(200).json(chain);
  } catch (error) {
    handleError(error, res);
  }
};

export const importCAController = async (req, res) => {
  try {
    const ca = await importExistingCA(req.body);
    res.status(201).json(ca);
  } catch (error) {
    handleError(error, res);
  }
};

export const exportCAController = async (req, res) => {
  try {
    const ca = await exportCA(req.params.caId);
    res.status(200).json(ca);
  } catch (error) {
    handleError(error, res);
  }
};

export const updateCAController = async (req, res) => {
  try {
    const ca = await updateExistingCA(req.params.caId, req.body);
    res.status(200).json(ca);
  } catch (error) {
    handleError(error, res);
  }
};

export const deleteCAController = async (req, res) => {
  try {
    const ca = await deleteExistingCA(req.params.caId);
    res.status(200).json(ca);
  } catch (error) {
    handleError(error, res);
  }
};

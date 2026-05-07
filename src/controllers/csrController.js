import { handleError } from "../utils/handleError.js";
import {
  exportCsr,
  generateCsr,
  getAllCsrs,
  importExistingCsr,
  signCsrWithCa,
  getCsrsSummary,
} from "../services/csrService.js";

export const listCsrsController = async (_req, res) => {
  try {
    const csrs = await getAllCsrs();
    res.status(200).json(csrs);
  } catch (error) {
    handleError(error, res);
  }
};

export const createCsrController = async (req, res) => {
  try {
    const csr = await generateCsr(req.body);
    res.status(201).json(csr);
  } catch (error) {
    handleError(error, res);
  }
};

export const importCsrController = async (req, res) => {
  try {
    const csr = await importExistingCsr(req.body);
    res.status(201).json(csr);
  } catch (error) {
    handleError(error, res);
  }
};

export const signCsrController = async (req, res) => {
  try {
    const result = await signCsrWithCa(req.params.csrId, req.body);
    res.status(201).json(result);
  } catch (error) {
    handleError(error, res);
  }
};

export const exportCsrController = async (req, res) => {
  try {
    const exported = await exportCsr(req.params.csrId);
    res.status(200).json(exported);
  } catch (error) {
    handleError(error, res);
  }
};

export const listCsrsSummaryController = async (_req, res) => {
  try {
    const csrs = await getCsrsSummary();
    res.status(200).json(csrs);
  } catch (error) {
    handleError(error, res);
  }
};
import { handleError } from "../utils/handleError.js";
import {
  exportCertificate,
  generateCertificate,
  getAllCertificates,
  getCertificateDetails,
  importExistingCertificate,
  signCertificate,
} from "../services/certService.js";

export const listCertificatesController = async (_req, res) => {
  try {
    const certificates = await getAllCertificates();
    res.status(200).json(certificates);
  } catch (error) {
    handleError(error, res);
  }
};

export const generateCertificateController = async (req, res) => {
  try {
    const certificate = await generateCertificate(req.body);
    res.status(201).json(certificate);
  } catch (error) {
    handleError(error, res);
  }
};

export const signCertificateController = async (req, res) => {
  try {
    const certificate = await signCertificate(req.params.certId, req.body);
    res.status(200).json(certificate);
  } catch (error) {
    handleError(error, res);
  }
};

export const importCertificateController = async (req, res) => {
  try {
    const certificate = await importExistingCertificate(req.body);
    res.status(201).json(certificate);
  } catch (error) {
    handleError(error, res);
  }
};

export const exportCertificateController = async (req, res) => {
  try {
    const exported = await exportCertificate(req.params.certId, req.query.format);
    res.status(200).json(exported);
  } catch (error) {
    handleError(error, res);
  }
};

export const getCertificateDetailsController = async (req, res) => {
  try {
    const details = await getCertificateDetails(req.params.certId);
    res.status(200).json(details);
  } catch (error) {
    handleError(error, res);
  }
};

import { Router } from "express";
import {
  deleteCertificateController,
  exportCertificateController,
  generateCertificateController,
  getCertificateDetailsController,
  importCertificateController,
  listCertificatesController,
  signCertificateController,
  updateCertificateController,
} from "../controllers/certController.js";
import { validateCertificateCreation, validateCertificateImport, validateCertificateSigning } from "../middlewares/validateCertificatePayload.js";
import { validateIdParam } from "../middlewares/validateIdParam.js";

const router = Router();

router.get("/", listCertificatesController);
router.post("/generate", validateCertificateCreation, generateCertificateController);
router.post("/import", validateCertificateImport, importCertificateController);
router.post("/:certId/sign", validateIdParam("certId"), validateCertificateSigning, signCertificateController);
router.get("/:certId/export", validateIdParam("certId"), exportCertificateController);
router.get("/:certId/details", validateIdParam("certId"), getCertificateDetailsController);
router.put("/:certId", validateIdParam("certId"), updateCertificateController);
router.delete("/:certId", validateIdParam("certId"), deleteCertificateController);

export default router;

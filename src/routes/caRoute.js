import { Router } from "express";
import {
  createIntermediateCAController,
  createRootCAController,
  deleteCAController,
  exportCAController,
  exportCAFileController,
  getTrustChainController,
  importCAController,
  listCAsController,
  updateCAController,
} from "../controllers/caController.js";
import { validateIdParam } from "../middlewares/validateIdParam.js";
import {
  mapCAUploadFilesToBody,
  uploadCAFiles,
} from "../middlewares/uploadCAFiles.js";

const router = Router();

router.get("/", listCAsController);
router.post("/caroot", createRootCAController);
router.post("/caintermediate", createIntermediateCAController);
router.post(
  "/import",
  uploadCAFiles,
  mapCAUploadFilesToBody,
  importCAController,
);
router.get("/:caId/chain", validateIdParam("caId"), getTrustChainController);
router.get("/:caId/export", validateIdParam("caId"), exportCAController);
router.get(
  "/:caId/export/:fileKind",
  validateIdParam("caId"),
  exportCAFileController,
);
router.put("/:caId", validateIdParam("caId"), updateCAController);
router.delete("/:caId", validateIdParam("caId"), deleteCAController);

export default router;

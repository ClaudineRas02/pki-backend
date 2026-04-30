import { Router } from "express";
import {
  createIntermediateCAController,
  createRootCAController,
  deleteCAController,
  exportCAController,
  getTrustChainController,
  importCAController,
  listCAsController,
  updateCAController,
} from "../controllers/caController.js";
import { validateIdParam } from "../middlewares/validateIdParam.js";

const router = Router();

router.get("/", listCAsController);
router.post("/caroot", createRootCAController);
router.post("/caintermediate", createIntermediateCAController);
router.post("/import", importCAController);
router.get("/:caId/chain", validateIdParam("caId"), getTrustChainController);
router.get("/:caId/export", validateIdParam("caId"), exportCAController);
router.put("/:caId", validateIdParam("caId"), updateCAController);
router.delete("/:caId", validateIdParam("caId"), deleteCAController);

export default router;

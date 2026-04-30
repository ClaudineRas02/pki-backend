import { Router } from "express";
import {
  createIntermediateCAController,
  createRootCAController,
  exportCAController,
  getTrustChainController,
  importCAController,
  listCAsController,
} from "../controllers/caController.js";

const router = Router();

router.get("/", listCAsController);
router.post("/caroot", createRootCAController);
router.post("/caintermediate", createIntermediateCAController);
router.get("/:caId/chain", getTrustChainController);
router.post("/import", importCAController);
router.get("/:caId/export", exportCAController);

export default router;

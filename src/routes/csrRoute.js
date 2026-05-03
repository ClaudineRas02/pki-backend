import { Router } from "express";
import {
  createCsrController,
  exportCsrController,
  importCsrController,
  listCsrsController,
  signCsrController,
} from "../controllers/csrController.js";
import { validateIdParam } from "../middlewares/validateIdParam.js";

const router = Router();

router.get("/", listCsrsController);
router.post("/", createCsrController);
router.post("/import", importCsrController);
router.post("/:csrId/submit", validateIdParam("csrId"), signCsrController);
router.get("/:csrId/export", validateIdParam("csrId"), exportCsrController);

export default router;

import { Router } from "express";
import { listArtifactsController } from "../controllers/artifactController.js";

const router = Router();

router.get("/", listArtifactsController);

export default router;

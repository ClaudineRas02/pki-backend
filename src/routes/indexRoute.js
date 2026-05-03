import { Router } from "express";
import artifactRoute from "./artifactRoute.js";
import caRoute from "./caRoute.js";
import certRoute from "./certRoute.js";
import csrRoute from "./csrRoute.js";

const router = Router();

router.get("/health", (_req, res) => {
  res.status(200).json({ status: "ok" });
});

router.use("/cas", caRoute);
router.use("/certificates", certRoute);
router.use("/csrs", csrRoute);
router.use("/artifacts", artifactRoute);

export default router;

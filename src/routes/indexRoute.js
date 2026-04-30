import { Router } from "express";
import caRoute from "./caRoute.js";
import certRoute from "./certRoute.js";

const router = Router();

router.get("/health", (_req, res) => {
  res.status(200).json({ status: "ok" });
});

router.use("/cas", caRoute);
router.use("/certificates", certRoute);

export default router;

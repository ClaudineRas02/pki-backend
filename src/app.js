import express from "express";
import cors from "cors";
import morgan from "morgan";
import indexRoute from "./routes/indexRoute.js";
import { errorHandler } from "./middlewares/errorHandler.js";

const app = express();

app.use(
  cors({
    origin: "exp://10.231.208.134:8081",
    credentials: true,
  }),
);
app.use(express.json({ limit: "15mb" }));
app.use(express.urlencoded({ extended: true }));
app.use(morgan("dev"));

app.use("/api", indexRoute);
app.use(errorHandler);

export default app;

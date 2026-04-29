import express from "express";
import cors from "cors";
import morgan from "morgan";
import indexRoute from "./routes/indexRoute.js";

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use(morgan("dev"));

app.use(
  cors({
    origin: ["exp://10.104.87.134:8081"],
    credentials: true,
  }),
);

app.use("/api", indexRoute);

export default app;

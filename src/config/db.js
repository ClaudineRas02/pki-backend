import { env } from "./env.js";
import { Pool } from "pg";

export const pool = new Pool({
  connectionString: env.databaseUrl,
});

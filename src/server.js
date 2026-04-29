import { pool } from "./config/db.js";
import app from "./app.js";
import { env } from "./config/env.js";

const server = app.listen(env.port, env.ip, () => {
  console.log(`Serveur en écoute sur le port http://${env.ip}:${env.port}`);
});

const shutdown = (signal) => {
  console.log(`Signal ${signal} reçu, fermeture du serveur`);
  server.close(async () => {
    await pool.end();
    process.exit(0);
  });
};

process.on("SIGINT", () => shutdown("SIGINT"));
process.on("SIGTERM", () => shutdown("SIGTERM"));

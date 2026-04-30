import "dotenv/config";

export const env = {
  ip: process.env.IP || "0.0.0.0",
  port: Number(process.env.PORT || 3000),
  databaseUrl: process.env.DATABASE_URL || "",
};

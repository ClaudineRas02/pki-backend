import { pool } from "../config/db.js";

export const createCA = async ({
  name,
  caType,
  parentCaId = null,
  privateKey = null,
  certificate = null,
  expiresAt = null,
  status = "VALID",
}) => {
  const sql = `
        INSERT INTO certificate_authorities (
          name,
          ca_type,
          parent_ca_id,
          private_key,
          certificate,
          expires_at,
          status
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING *
    `;

  const { rows } = await pool.query(sql, [
    name,
    caType,
    parentCaId,
    privateKey,
    certificate,
    expiresAt,
    status,
  ]);
  return rows[0];
};

export const findCAById = async (caId) => {
  const { rows } = await pool.query(
    `
      SELECT *
      FROM certificate_authorities
      WHERE ca_id = $1
    `,
    [caId],
  );

  return rows[0] || null;
};

export const listCAs = async () => {
  const { rows } = await pool.query(`
    SELECT *
    FROM certificate_authorities
    ORDER BY created_at DESC, ca_id DESC
  `);

  return rows;
};

//CA → puis son parent → puis le parent du parent → jusqu’à la racine
export const getTrustChain = async (caId) => {
  const { rows } = await pool.query(
    `
      WITH RECURSIVE ca_chain AS (
        SELECT
          ca_id,
          name,
          ca_type,
          parent_ca_id,
          private_key,
          certificate,
          expires_at,
          status,
          created_at,
          0 AS depth
        FROM certificate_authorities
        WHERE ca_id = $1

        UNION ALL

        SELECT
          parent.ca_id,
          parent.name,
          parent.ca_type,
          parent.parent_ca_id,
          parent.private_key,
          parent.certificate,
          parent.expires_at,
          parent.status,
          parent.created_at,
          child.depth + 1 AS depth
        FROM certificate_authorities parent
        INNER JOIN ca_chain child ON parent.ca_id = child.parent_ca_id
      )
      SELECT *
      FROM ca_chain
      ORDER BY depth DESC, ca_id ASC
    `,
    [caId],
  );

  return rows;
};

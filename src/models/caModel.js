import { pool } from "../config/db.js";

export const createCA = async ({
  name,
  caType,
  parentCaId = null,
  privateKey = null,
  certificate = null,
  expiresAt = null,
  status = "VALID",
  subjectDn = null,
  issuerDn = null,
  serialNumber = null,
  fingerprintSha256 = null,
  keyPath = null,
  certPath = null,
  serialPath = null,
  sourceFormat = null,
}) => {
  const sql = `
        INSERT INTO certificate_authorities (
          name,
          ca_type,
          parent_ca_id,
          private_key,
          certificate,
          expires_at,
          status,
          subject_dn,
          issuer_dn,
          serial_number,
          fingerprint_sha256,
          key_path,
          cert_path,
          serial_path,
          source_format
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)
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
    subjectDn,
    issuerDn,
    serialNumber,
    fingerprintSha256,
    keyPath,
    certPath,
    serialPath,
    sourceFormat,
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

export const updateCA = async (
  caId,
  {
    name,
    caType,
    parentCaId,
    privateKey,
    certificate,
    expiresAt,
    status,
    subjectDn,
    issuerDn,
    serialNumber,
    fingerprintSha256,
    keyPath,
    certPath,
    serialPath,
    sourceFormat,
  },
) => {
  const { rows } = await pool.query(
    `
      UPDATE certificate_authorities
      SET name = $2,
          ca_type = $3,
          parent_ca_id = $4,
          private_key = $5,
          certificate = $6,
          expires_at = $7,
          status = $8,
          subject_dn = $9,
          issuer_dn = $10,
          serial_number = $11,
          fingerprint_sha256 = $12,
          key_path = $13,
          cert_path = $14,
          serial_path = $15,
          source_format = $16
      WHERE ca_id = $1
      RETURNING *
    `,
    [
      caId,
      name,
      caType,
      parentCaId,
      privateKey,
      certificate,
      expiresAt,
      status,
      subjectDn,
      issuerDn,
      serialNumber,
      fingerprintSha256,
      keyPath,
      certPath,
      serialPath,
      sourceFormat,
    ],
  );

  return rows[0] || null;
};

export const deleteCA = async (caId) => {
  const { rows } = await pool.query(
    `
      DELETE FROM certificate_authorities
      WHERE ca_id = $1
      RETURNING *
    `,
    [caId],
  );

  return rows[0] || null;
};

export const countChildCAs = async (caId) => {
  const { rows } = await pool.query(
    `
      SELECT COUNT(*)::integer AS total
      FROM certificate_authorities
      WHERE parent_ca_id = $1
    `,
    [caId],
  );

  return rows[0].total;
};

export const countLinkedCertificates = async (caId) => {
  const { rows } = await pool.query(
    `
      SELECT COUNT(*)::integer AS total
      FROM certificates
      WHERE ca_id = $1
    `,
    [caId],
  );

  return rows[0].total;
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

export const listCAsSummary = async () => {
  const { rows } = await pool.query(`
    SELECT ca_id, name
    FROM certificate_authorities
    ORDER BY created_at DESC, ca_id DESC
  `);

  return rows;
};

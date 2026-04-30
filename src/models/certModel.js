import { pool } from "../config/db.js";

export const createCertificate = async ({
  commonName,
  certType,
  algorithm,
  expiresAt = null,
  status = "VALID",
  caId = null,
}) => {
  const { rows } = await pool.query(
    `
      INSERT INTO certificates (
        common_name,
        cert_type,
        algorithm,
        expires_at,
        status,
        ca_id
      )
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING *
    `,
    [commonName, certType, algorithm, expiresAt, status, caId],
  );

  return rows[0];
};

export const findCertificateById = async (certId) => {
  const { rows } = await pool.query(
    `
      SELECT c.*, ca.name AS ca_name, ca.ca_type
      FROM certificates c
      LEFT JOIN certificate_authorities ca ON ca.ca_id = c.ca_id
      WHERE c.cert_id = $1
    `,
    [certId],
  );

  return rows[0] || null;
};

export const listCertificates = async () => {
  const { rows } = await pool.query(`
    SELECT c.*, ca.name AS ca_name, ca.ca_type
    FROM certificates c
    LEFT JOIN certificate_authorities ca ON ca.ca_id = c.ca_id
    ORDER BY c.issued_at DESC, c.cert_id DESC
  `);

  return rows;
};

//signer cert en definissant son ca
export const updateCertificateCA = async (certId, caId) => {
  const { rows } = await pool.query(
    `
      UPDATE certificates
      SET ca_id = $2,
          issued_at = CURRENT_TIMESTAMP,
          status = 'VALID'
      WHERE cert_id = $1
      RETURNING *
    `,
    [certId, caId],
  );

  return rows[0] || null;
};

export const updateCertificate = async (
  certId,
  { commonName, certType, algorithm, expiresAt, status, caId },
) => {
  const { rows } = await pool.query(
    `
      UPDATE certificates
      SET common_name = $2,
          cert_type = $3,
          algorithm = $4,
          expires_at = $5,
          status = $6,
          ca_id = $7
      WHERE cert_id = $1
      RETURNING *
    `,
    [certId, commonName, certType, algorithm, expiresAt, status, caId],
  );

  return rows[0] || null;
};

export const deleteCertificate = async (certId) => {
  const { rows } = await pool.query(
    `
      DELETE FROM certificates
      WHERE cert_id = $1
      RETURNING *
    `,
    [certId],
  );

  return rows[0] || null;
};

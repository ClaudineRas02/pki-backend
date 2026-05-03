import { pool } from "../config/db.js";

export const createCsr = async ({
  commonName,
  algorithm,
  status = "PENDING",
  subjectDn = null,
  csr = null,
  privateKey = null,
  csrPath = null,
  keyPath = null,
  sourceFormat = null,
  signedCertificateId = null,
  caId = null,
}) => {
  const { rows } = await pool.query(
    `
      INSERT INTO certificate_signing_requests (
        common_name,
        algorithm,
        status,
        subject_dn,
        csr,
        private_key,
        csr_path,
        key_path,
        source_format,
        signed_certificate_id,
        ca_id
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
      RETURNING *
    `,
    [
      commonName,
      algorithm,
      status,
      subjectDn,
      csr,
      privateKey,
      csrPath,
      keyPath,
      sourceFormat,
      signedCertificateId,
      caId,
    ],
  );

  return rows[0];
};

export const findCsrById = async (csrId) => {
  const { rows } = await pool.query(
    `
      SELECT csr.*, ca.name AS ca_name, cert.common_name AS certificate_common_name
      FROM certificate_signing_requests csr
      LEFT JOIN certificate_authorities ca ON ca.ca_id = csr.ca_id
      LEFT JOIN certificates cert ON cert.cert_id = csr.signed_certificate_id
      WHERE csr.csr_id = $1
    `,
    [csrId],
  );

  return rows[0] || null;
};

export const listCsrs = async () => {
  const { rows } = await pool.query(`
    SELECT csr.*, ca.name AS ca_name, cert.common_name AS certificate_common_name
    FROM certificate_signing_requests csr
    LEFT JOIN certificate_authorities ca ON ca.ca_id = csr.ca_id
    LEFT JOIN certificates cert ON cert.cert_id = csr.signed_certificate_id
    ORDER BY csr.created_at DESC, csr.csr_id DESC
  `);

  return rows;
};

export const updateCsr = async (
  csrId,
  { status, signedCertificateId, caId },
) => {
  const { rows } = await pool.query(
    `
      UPDATE certificate_signing_requests
      SET status = $2,
          signed_certificate_id = $3,
          ca_id = $4
      WHERE csr_id = $1
      RETURNING *
    `,
    [csrId, status, signedCertificateId, caId],
  );

  return rows[0] || null;
};

export const listCsrSans = async (csrId) => {
  const { rows } = await pool.query(
    `
      SELECT domain
      FROM csr_sans
      WHERE csr_id = $1
      ORDER BY csr_san_id ASC
    `,
    [csrId],
  );

  return rows.map((row) => row.domain);
};

export const replaceCsrSans = async (csrId, sanList = []) => {
  await pool.query(
    `
      DELETE FROM csr_sans
      WHERE csr_id = $1
    `,
    [csrId],
  );

  for (const san of sanList) {
    await pool.query(
      `
        INSERT INTO csr_sans (csr_id, domain)
        VALUES ($1, $2)
      `,
      [csrId, san],
    );
  }
};

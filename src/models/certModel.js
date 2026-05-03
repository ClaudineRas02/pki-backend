import { pool } from "../config/db.js";

export const createCertificate = async ({
  commonName,
  certType,
  algorithm,
  expiresAt = null,
  status = "VALID",
  caId = null,
  subjectDn = null,
  issuerDn = null,
  serialNumber = null,
  fingerprintSha256 = null,
  keyPath = null,
  certPath = null,
  sourceFormat = null,
  csrId = null,
}) => {
  const { rows } = await pool.query(
    `
      INSERT INTO certificates (
        common_name,
        cert_type,
        algorithm,
        expires_at,
        status,
        ca_id,
        subject_dn,
        issuer_dn,
        serial_number,
        fingerprint_sha256,
        key_path,
        cert_path,
        source_format,
        csr_id
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
      RETURNING *
    `,
    [
      commonName,
      certType,
      algorithm,
      expiresAt,
      status,
      caId,
      subjectDn,
      issuerDn,
      serialNumber,
      fingerprintSha256,
      keyPath,
      certPath,
      sourceFormat,
      csrId,
    ],
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

export const listCertificateSans = async (certId) => {
  const { rows } = await pool.query(
    `
      SELECT domain
      FROM certificate_sans
      WHERE certificate_id = $1
      ORDER BY san_id ASC
    `,
    [certId],
  );

  return rows.map((row) => row.domain);
};

export const replaceCertificateSans = async (certId, sanList = []) => {
  await pool.query(
    `
      DELETE FROM certificate_sans
      WHERE certificate_id = $1
    `,
    [certId],
  );

  for (const san of sanList) {
    await pool.query(
      `
        INSERT INTO certificate_sans (certificate_id, domain)
        VALUES ($1, $2)
      `,
      [certId, san],
    );
  }
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
  {
    commonName,
    certType,
    algorithm,
    expiresAt,
    status,
    caId,
    subjectDn,
    issuerDn,
    serialNumber,
    fingerprintSha256,
    keyPath,
    certPath,
    sourceFormat,
    csrId,
  },
) => {
  const { rows } = await pool.query(
    `
      UPDATE certificates
      SET common_name = $2,
          cert_type = $3,
          algorithm = $4,
          expires_at = $5,
          status = $6,
          ca_id = $7,
          subject_dn = $8,
          issuer_dn = $9,
          serial_number = $10,
          fingerprint_sha256 = $11,
          key_path = $12,
          cert_path = $13,
          source_format = $14,
          csr_id = $15
      WHERE cert_id = $1
      RETURNING *
    `,
    [
      certId,
      commonName,
      certType,
      algorithm,
      expiresAt,
      status,
      caId,
      subjectDn,
      issuerDn,
      serialNumber,
      fingerprintSha256,
      keyPath,
      certPath,
      sourceFormat,
      csrId,
    ],
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

import { listCAs } from "../models/caModel.js";
import { listCertificates } from "../models/certModel.js";
import { listCsrs } from "../models/csrModel.js";

const toTimestamp = (value) => (value ? new Date(value).getTime() : 0);

export const listArtifacts = async () => {
  const [cas, csrs, certificates] = await Promise.all([
    listCAs(),
    listCsrs(),
    listCertificates(),
  ]);

  return [
    ...cas.map((item) => ({
      artifact_id: `ca-${item.ca_id}`,
      type: "CA",
      id: item.ca_id,
      name: item.name,
      status: item.status,
      created_at: item.created_at,
      expires_at: item.expires_at,
      source_format: item.source_format,
      file_paths: {
        certificate: item.cert_path,
        private_key: item.key_path,
        serial: item.serial_path,
      },
    })),
    ...csrs.map((item) => ({
      artifact_id: `csr-${item.csr_id}`,
      type: "CSR",
      id: item.csr_id,
      name: item.common_name,
      status: item.status,
      created_at: item.created_at,
      source_format: item.source_format,
      file_paths: {
        csr: item.csr_path,
        private_key: item.key_path,
      },
      signed_certificate_id: item.signed_certificate_id,
      ca_id: item.ca_id,
    })),
    ...certificates.map((item) => ({
      artifact_id: `crt-${item.cert_id}`,
      type: "CRT",
      id: item.cert_id,
      name: item.common_name,
      status: item.status,
      created_at: item.issued_at,
      expires_at: item.expires_at,
      source_format: item.source_format,
      file_paths: {
        certificate: item.cert_path,
        private_key: item.key_path,
      },
      ca_id: item.ca_id,
      csr_id: item.csr_id,
    })),
  ].sort((a, b) => toTimestamp(b.created_at) - toTimestamp(a.created_at));
};

import {pool} from "../config/db.js";


export async function GetExpiringCertificateMails() {
    try {
        const { rows } = await pool.query(`
            SELECT
                cert_id,
                common_name,
                expires_at,
                substring(subject_dn FROM 'emailAddress=([^, ]+)') AS email
            FROM certificates
            WHERE
                expires_at IS NOT NULL
                AND expires_at <= NOW() + INTERVAL '7 days'
                AND expires_at > NOW()
                AND subject_dn ~ 'emailAddress='
            ORDER BY expires_at ASC;
        `);

        return rows;

    } catch (e) {
        console.error(e);
        throw e;
    }
}
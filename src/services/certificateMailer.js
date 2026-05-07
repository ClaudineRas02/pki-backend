import { GetExpiringCertificateMails } from "../models/mailModel.js";
import { sendExpiryMail } from "./mailService.js";

export async function notifyExpiringCertificates() {
    const certificates = await GetExpiringCertificateMails();

    await Promise.all(
        certificates
            .filter(cert => cert.email)
            .map(cert =>
                sendExpiryMail(cert).catch(e =>
                    console.error(`Échec de l'envoi à ${cert.email}:`, e.message)
                )
            )
    );
}
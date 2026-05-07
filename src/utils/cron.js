import cron from "node-cron";
import { notifyExpiringCertificates } from "../services/certificateMailer.js";

cron.schedule("30 8 * * *", async () => {
    console.log("[ Task ] Vérification des certificats expirants...");
    await notifyExpiringCertificates();
    console.log("[ Done ] Tache de verification de certificats expirants terminé");
});
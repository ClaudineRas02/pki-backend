import nodemailer from "nodemailer";

const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
        user: process.env.MAIL_USER,
        pass: process.env.MAIL_PASS,
    },
});

export async function sendExpiryMail({ email, common_name, expires_at }) {
    const expiryDate = new Date(expires_at).toLocaleDateString("fr-FR");

    await transporter.sendMail({
        from: `"Sécurité Certificats" <${process.env.MAIL_USER}>`,
        to: email,
        subject: "Expiration imminente de votre certificat",
        html: `
      <p>Bonjour,</p>
      <p>Nous vous informons que votre certificat <strong>${common_name}</strong> expirera le <strong>${expiryDate}</strong>.</p>
      <p>Veuillez le renouveler avant cette date afin d'éviter toute interruption de service.</p>
      <p>Cordialement,<br/>L'équipe Sécurité</p>
    `,
    });
}
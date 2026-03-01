const nodemailer = require('nodemailer');

// centralize email configuration
const transporter = nodemailer.createTransport({
    host: 'smtp.gmail.com',
    port: 587,
    secure: false, // Use STARTTLS
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
    },
    tls: {
        rejectUnauthorized: false // Helps with some self-signed certificate issues or restrictive networks
    },
    connectionTimeout: 20000, // 20 seconds
    greetingTimeout: 20000,
    socketTimeout: 30000
});

const sendEmail = async ({ to, subject, text, html }) => {
    const mailOptions = {
        from: `"Portfolio Service" <${process.env.EMAIL_USER}>`,
        to,
        subject,
        text,
        html
    };

    try {
        console.log(`[MAILER] Attempting to send email to ${to}...`);
        const info = await transporter.sendMail(mailOptions);
        console.log(`✔ [MAILER] Email sent: ${info.messageId}`);
        return info;
    } catch (error) {
        console.error(`✘ [MAILER] Error sending email to ${to}:`, error.message);
        throw error;
    }
};

module.exports = { sendEmail };

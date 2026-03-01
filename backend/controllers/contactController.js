const { sendEmail } = require('../utils/mailer');
const Contact = require('../models/Contact');

exports.sendMessage = async (req, res) => {
    try {
        const { name, email, mobile, message } = req.body;

        if (!name || !email || !mobile) {
            return res.status(400).json({ message: 'Name, email, and mobile are required' });
        }

        // Save to Database for Analytics
        const newContact = new Contact({ name, email, mobile, message });
        await newContact.save();

        // Send email using shared utility
        await sendEmail({
            to: 'daxpatel230005@gmail.com',
            subject: `New Portfolio Contact: ${name}`,
            text: `
        New contact inquiry from your portfolio:
        
        Name: ${name}
        Email: ${email}
        Mobile: ${mobile}
        Message: ${message || 'No additional message provided'}
      `,
            html: `
        <h3>New contact inquiry from your portfolio</h3>
        <p><strong>Name:</strong> ${name}</p>
        <p><strong>Email:</strong> ${email}</p>
        <p><strong>Mobile:</strong> ${mobile}</p>
        <p><strong>Message:</strong> ${message || 'No additional message provided'}</p>
      `
        });

        res.status(200).json({ message: 'Message sent successfully' });
    } catch (error) {
        console.error('Email sending error:', error);
        res.status(500).json({ message: 'Failed to send message', details: error.message });
    }
};

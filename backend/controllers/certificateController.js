const Certificate = require('../models/Certificate');
const fs = require('fs');
const path = require('path');

exports.getCertificates = async (req, res) => {
    try {
        const certificates = await Certificate.find().sort({ createdAt: -1 });
        res.json(certificates);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.createCertificate = async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ error: 'No file uploaded' });
        }

        const { name, description } = req.body;
        if (!name) {
            return res.status(400).json({ error: 'Certificate name is required' });
        }

        const fileUrl = `/uploads/${req.file.filename}`;
        const certificate = new Certificate({
            name,
            description,
            fileUrl
        });

        await certificate.save();
        res.status(201).json(certificate);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
};

exports.deleteCertificate = async (req, res) => {
    try {
        const certificate = await Certificate.findById(req.params.id);
        if (!certificate) {
            return res.status(404).json({ error: 'Certificate not found' });
        }

        // Delete file from filesystem
        const filePath = path.join(__dirname, '..', certificate.fileUrl);
        if (fs.existsSync(filePath)) {
            fs.unlinkSync(filePath);
        }

        await Certificate.findByIdAndDelete(req.params.id);
        res.json({ message: 'Certificate deleted successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.deleteCertificatesBulk = async (req, res) => {
    try {
        const { ids } = req.body;
        if (!Array.isArray(ids)) return res.status(400).json({ error: 'IDs must be an array' });

        const certificates = await Certificate.find({ _id: { $in: ids } });

        // Delete files
        for (const cert of certificates) {
            if (cert.fileUrl) {
                const filePath = path.join(__dirname, '..', cert.fileUrl);
                if (fs.existsSync(filePath)) {
                    fs.unlinkSync(filePath);
                }
            }
        }

        await Certificate.deleteMany({ _id: { $in: ids } });
        res.json({ message: 'Certificates deleted' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

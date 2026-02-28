const Language = require('../models/Language');

exports.getLanguages = async (req, res) => {
    try {
        const languages = await Language.find().sort({ createdAt: 1 });
        res.json(languages);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.addLanguage = async (req, res) => {
    try {
        const { name, proficiency } = req.body;
        const newLang = new Language({ name, proficiency });
        await newLang.save();
        res.status(201).json(newLang);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
};

exports.deleteLanguage = async (req, res) => {
    try {
        await Language.findByIdAndDelete(req.params.id);
        res.json({ message: 'Language deleted' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

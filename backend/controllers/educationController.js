const Education = require('../models/Education');

exports.getEducation = async (req, res) => {
  try {
    const educations = await Education.find();
    console.log(`[GET] /api/education - Found ${educations.length} entries`);
    res.json(educations);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.getEducationById = async (req, res) => {
  try {
    const education = await Education.findById(req.params.id);
    if (!education) return res.status(404).json({ message: 'Not found' });
    res.json(education);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.createEducation = async (req, res) => {
  try {
    const data = { ...req.body };
    if (req.file) {
      data.certificateUrl = `/uploads/${req.file.filename}`;
    }
    const edu = new Education(data);
    await edu.save();
    res.status(201).json(edu);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.updateEducation = async (req, res) => {
  try {
    const data = { ...req.body };
    if (req.file) {
      data.certificateUrl = `/uploads/${req.file.filename}`;
    }
    const edu = await Education.findByIdAndUpdate(req.params.id, data, { new: true });
    if (!edu) return res.status(404).json({ message: 'Not found' });
    res.json(edu);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.deleteEducation = async (req, res) => {
  try {
    await Education.findByIdAndDelete(req.params.id);
    res.json({ message: 'Deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.updateCertificate = async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ error: 'No file uploaded' });
    const certificateUrl = `/uploads/${req.file.filename}`;
    const edu = await Education.findByIdAndUpdate(req.params.id, { certificateUrl }, { new: true });
    if (!edu) return res.status(404).json({ message: 'Not found' });
    res.json(edu);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.deleteCertificate = async (req, res) => {
  try {
    const edu = await Education.findByIdAndUpdate(req.params.id, { $unset: { certificateUrl: 1 } }, { new: true });
    if (!edu) return res.status(404).json({ message: 'Not found' });
    res.json(edu);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

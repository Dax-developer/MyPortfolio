const Profile = require('../models/Profile');

exports.getProfile = async (req, res) => {
  try {
    let profile = await Profile.findOne();
    if (!profile) {
      profile = new Profile();
      await profile.save();
    }
    res.json(profile);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.updateProfile = async (req, res) => {
  try {
    let profile = await Profile.findOne();
    if (!profile) {
      profile = new Profile();
    }

    // Update fields
    Object.keys(req.body).forEach(key => {
      if (key !== '_id') {
        profile[key] = req.body[key];
      }
    });

    profile.updatedAt = Date.now();
    await profile.save();
    res.json(profile);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.uploadResume = async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ error: 'No file uploaded' });
    const resumeUrl = `/uploads/${req.file.filename}`;
    let profile = await Profile.findOne();
    if (!profile) profile = new Profile();
    profile.resumeUrl = resumeUrl;
    profile.updatedAt = Date.now();
    await profile.save();
    res.json(profile);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.deleteResume = async (req, res) => {
  try {
    const profile = await Profile.findOneAndUpdate({}, { $unset: { resumeUrl: 1 } }, { new: true });
    if (!profile) return res.status(404).json({ message: 'Profile not found' });
    res.json(profile);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
exports.uploadPhoto = async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ error: 'No file uploaded' });
    const photoUrl = `/uploads/${req.file.filename}`;
    let profile = await Profile.findOne();
    if (!profile) profile = new Profile();
    profile.photoUrl = photoUrl;
    profile.updatedAt = Date.now();
    await profile.save();
    res.json(profile);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.deletePhoto = async (req, res) => {
  try {
    const profile = await Profile.findOneAndUpdate({}, { $unset: { photoUrl: 1 } }, { new: true });
    if (!profile) return res.status(404).json({ message: 'Profile not found' });
    res.json(profile);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

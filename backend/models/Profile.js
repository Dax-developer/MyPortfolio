const mongoose = require('mongoose');

const ProfileSchema = new mongoose.Schema({
  name: String,
  title: String,
  bio: String,
  photoUrl: String,
  resumeUrl: String,
  email: String,
  phone: String,
  location: String,
  socialLinks: [String],
  heroSkills: String,
  footerBrandName: String,
  footerTagline: String,
  footerEmail: String,
  footerLocation: String,
  footerLinkedIn: String,
  footerGitHub: String,
  footerInstagram: String,
  footerWhatsApp: String,
  footerCopyright: String,
  footerCredit: String,
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Profile', ProfileSchema);

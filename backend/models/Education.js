const mongoose = require('mongoose');

const EducationSchema = new mongoose.Schema({
  institution: String, // College / University
  degree: String,
  year: String, // Graduation Year
  grade: String, // CGPA / Percentage
  certificateUrl: String,
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Education', EducationSchema);

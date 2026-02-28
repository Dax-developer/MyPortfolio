const mongoose = require('mongoose');

const ExperienceSchema = new mongoose.Schema({
  company: { type: String },
  position: { type: String },
  description: String,
  technologies: [String],
  startDate: { type: String },
  endDate: String,
  isCurrently: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Experience', ExperienceSchema);

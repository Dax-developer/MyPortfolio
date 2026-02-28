const mongoose = require('mongoose');

const ProjectSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: String,
  url: String, // Live Demo URL
  githubUrl: String,
  role: String, // e.g., "Individual" or "Team Lead"
  tech: [String],
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Project', ProjectSchema);

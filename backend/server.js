require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');
const { connectOnce } = require('./config/db');

const projectRoutes = require('./routes/projectRoutes');
const skillRoutes = require('./routes/skillRoutes');
const experienceRoutes = require('./routes/experienceRoutes');
const educationRoutes = require('./routes/educationRoutes');
const profileRoutes = require('./routes/profileRoutes');
const resumeRoutes = require('./routes/resumeRoutes');
const authRoutes = require('./routes/authRoutes');
const contactRoutes = require('./routes/contactRoutes');
const certificateRoutes = require('./routes/certificateRoutes');
const announcementRoutes = require('./routes/announcementRoutes');
const languageRoutes = require('./routes/languageRoutes');
const analyticsRoutes = require('./routes/analyticsRoutes');
const auth = require('./middleware/authMiddleware');

const app = express();
app.use(cors());
app.use(express.json());

// Debug: Log all requests
app.use((req, res, next) => {
  console.log(`[DEBUG] ${new Date().toISOString()} - ${req.method} ${req.originalUrl}`);
  next();
});

app.use('/api/auth', authRoutes);
app.use('/api/projects', projectRoutes);
app.use('/api/skills', skillRoutes);
app.use('/api/experience', experienceRoutes);
app.use('/api/education', educationRoutes);
app.use('/api/profile', profileRoutes);
app.use('/api/resume', resumeRoutes);
app.use('/api/contact', contactRoutes);
app.use('/api/certificates', certificateRoutes);
app.use('/api/announcements', announcementRoutes);
app.use('/api/languages', languageRoutes);
app.use('/api/portfolio', analyticsRoutes);
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Serve Frontend Static Files
const frontendPath = path.join(__dirname, 'public');
app.use(express.static(frontendPath));

// Handle SPA Routing - Redirect all non-API requests to index.html
app.get('*', (req, res, next) => {
  if (req.url.startsWith('/api') || req.url.startsWith('/uploads')) {
    return next();
  }
  res.sendFile(path.join(frontendPath, 'index.html'));
});

// Database Connection Middleware for Serverless
const dbMiddleware = async (req, res, next) => {
  try {
    await connectOnce();
    next();
  } catch (err) {
    res.status(500).json({ error: 'Database connection failed' });
  }
};

app.use('/api', dbMiddleware);

const PORT = process.env.PORT || 5000;

if (process.env.VERCEL) {
  module.exports = app;
} else {
  const start = async () => {
    try {
      await connectOnce();
      const server = app.listen(PORT, () => {
        console.log(`\x1b[32m%s\x1b[0m`, `✔ Server running on port ${PORT}`);
      });

      server.on('error', (e) => {
        if (e.code === 'EADDRINUSE') {
          console.error(`\x1b[31m%s\x1b[0m`, `❌ Error: Port ${PORT} is already in use.`);
          process.exit(1);
        }
      });
    } catch (err) {
      console.error('Failed to start server:', err);
      process.exit(1);
    }
  };
  start();
}

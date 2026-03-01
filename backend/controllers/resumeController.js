const Project = require('../models/Project');
const Skill = require('../models/Skill');
const Experience = require('../models/Experience');
const Education = require('../models/Education');
const Profile = require('../models/Profile');
const puppeteer = require('puppeteer-core');
// chrome-launcher is ESM only, will be loaded dynamically in the function
const path = require('path');
const fs = require('fs');

exports.downloadResume = async (req, res) => {
  let browser = null;
  try {
    // 1. Fetch all data
    const [profile, projects, skills, experiences, educations] = await Promise.all([
      Profile.findOne(),
      Project.find().sort({ createdAt: -1 }),
      Skill.find(),
      Experience.find().sort({ createdAt: -1 }),
      Education.find().sort({ createdAt: -1 })
    ]);

    if (!profile) return res.status(404).json({ message: 'Profile not found' });

    // 2. Generate HTML
    const html = generateResumeHtml(profile, projects, skills, experiences, educations);

    // 3. Launch Browser and Generate PDF
    let chromePath;
    try {
      const { getChromePath } = await import('chrome-launcher');
      chromePath = getChromePath();
    } catch (e) {
      console.log('chrome-launcher dynamic import failed or not supported, trying fallback...');
    }

    // Fallback for Render (Linux)
    if (!chromePath && (process.env.RENDER || process.platform === 'linux')) {
      const possiblePaths = [
        '/usr/bin/google-chrome-stable',
        '/usr/bin/google-chrome',
        '/usr/bin/chromium',
        '/usr/bin/chromium-browser'
      ];
      for (const p of possiblePaths) {
        if (fs.existsSync(p)) {
          chromePath = p;
          break;
        }
      }
    }

    if (!chromePath) {
      throw new Error('No Chrome installation found. If on Render, please add the Google Chrome Buildpack.');
    }

    browser = await puppeteer.launch({
      executablePath: chromePath,
      headless: true,
      args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage']
    });

    const page = await browser.newPage();
    await page.setContent(html, { waitUntil: 'networkidle0' });

    const pdfBuffer = await page.pdf({
      format: 'A4',
      printBackground: true,
      margin: { top: '0px', right: '0px', bottom: '0px', left: '0px' }
    });

    await browser.close();
    browser = null;

    // 4. Send PDF explicitly as Binary
    const finalBuffer = Buffer.from(pdfBuffer);
    res.set({
      'Content-Type': 'application/pdf',
      'Content-Disposition': 'attachment; filename=resume.pdf',
      'Content-Length': finalBuffer.length
    });
    res.end(finalBuffer);

  } catch (error) {
    console.error('Resume generation error:', error);
    if (browser) await browser.close().catch(() => { });
    res.status(500).json({ error: 'Failed to generate resume', details: error.message });
  }
};

function generateResumeHtml(profile, projects, skills, experiences, educations) {
  const skillChips = skills.map(s => `<span class="chip">${s.name}</span>`).join('');

  const projectItems = projects.map(p => `
    <div class="item">
      <div class="item-header">
        <span class="item-title">${p.title}</span>
        <span class="item-meta">${p.role || ''}</span>
      </div>
      <p class="item-desc">${p.description || ''}</p>
      <div class="item-tech">${(p.tech || []).join(', ')}</div>
    </div>
  `).join('');

  const expItems = experiences.map(e => `
    <div class="item">
      <div class="item-header">
        <span class="item-title">${e.position}</span>
        <span class="item-meta">${e.company} | ${e.startDate} - ${e.isCurrently ? 'Present' : e.endDate}</span>
      </div>
      <p class="item-desc">${e.description || ''}</p>
    </div>
  `).join('');

  const eduItems = educations.map(e => `
    <div class="item">
      <div class="item-header">
        <span class="item-title">${e.degree}</span>
        <span class="item-meta">${e.institution} | ${e.year}</span>
      </div>
      <p class="item-desc">Grade: ${e.grade || 'N/A'}</p>
    </div>
  `).join('');

  return `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap');
        
        :root {
          --primary: #2563eb;
          --bg: #ffffff;
          --text: #1f2937;
          --text-light: #6b7280;
          --border: #e5e7eb;
        }

        * {
          margin: 0;
          padding: 0;
          box-sizing: border-box;
          font-family: 'Inter', sans-serif;
        }

        body {
          background: var(--bg);
          color: var(--text);
          line-height: 1.5;
        }

        .page {
          padding: 40px;
          display: grid;
          grid-template-columns: 1fr 2fr;
          gap: 40px;
          min-height: 100vh;
        }

        /* Sidebar Styles */
        .sidebar {
          border-right: 1px solid var(--border);
          padding-right: 20px;
        }

        .profile-pic {
          width: 150px;
          height: 150px;
          border-radius: 20px;
          background: #f3f4f6;
          margin-bottom: 24px;
          overflow: hidden;
        }

        h1 {
          font-size: 32px;
          font-weight: 700;
          color: var(--primary);
          margin-bottom: 8px;
        }

        .subtitle {
          font-size: 18px;
          color: var(--text-light);
          margin-bottom: 32px;
        }

        .section-title {
          font-size: 14px;
          text-transform: uppercase;
          letter-spacing: 0.1em;
          color: var(--primary);
          margin-bottom: 16px;
          font-weight: 600;
          border-bottom: 2px solid var(--primary);
          display: inline-block;
          padding-bottom: 4px;
        }

        .contact-item {
          margin-bottom: 12px;
          font-size: 14px;
        }

        .chip-container {
          display: flex;
          flex-wrap: wrap;
          gap: 8px;
          margin-bottom: 32px;
        }

        .chip {
          background: #eff6ff;
          color: var(--primary);
          padding: 4px 12px;
          border-radius: 6px;
          font-size: 12px;
          font-weight: 500;
        }

        /* Main Content Styles */
        .main-content {
          padding-left: 10px;
        }

        .item {
          margin-bottom: 24px;
        }

        .item-header {
          display: flex;
          justify-content: space-between;
          align-items: baseline;
          margin-bottom: 4px;
        }

        .item-title {
          font-size: 18px;
          font-weight: 600;
        }

        .item-meta {
          font-size: 13px;
          color: var(--text-light);
        }

        .item-desc {
          font-size: 14px;
          color: var(--text-light);
          margin-bottom: 8px;
        }

        .item-tech {
          font-size: 12px;
          font-style: italic;
          color: var(--primary);
        }

        @media print {
          .page { padding: 30px; }
        }
      </style>
    </head>
    <body>
      <div class="page">
        <div class="sidebar">
          <h1>${profile.name || 'Your Name'}</h1>
          <p class="subtitle">${profile.title || 'Full Stack Developer'}</p>
          
          <div class="section-title">Contact</div>
          <div class="contact-item">📧 ${profile.email || 'N/A'}</div>
          <div class="contact-item">📱 ${profile.phone || 'N/A'}</div>
          <div class="contact-item">📍 ${profile.location || 'N/A'}</div>
          
          <div style="margin-top: 32px;"></div>
          
          <div class="section-title">Skills</div>
          <div class="chip-container">
            ${skillChips}
          </div>

          <div class="section-title">About Me</div>
          <p style="font-size: 14px; color: var(--text-light);">${profile.bio || ''}</p>
        </div>

        <div class="main-content">
          <div class="section-title">Experience</div>
          ${expItems}

          <div class="section-title" style="margin-top: 32px;">Education</div>
          ${eduItems}

          <div class="section-title" style="margin-top: 32px;">Projects</div>
          ${projectItems}
        </div>
      </div>
    </body>
    </html>
  `;
}

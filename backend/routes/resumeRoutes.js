const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/resumeController');

router.get('/download', ctrl.downloadResume);

module.exports = router;

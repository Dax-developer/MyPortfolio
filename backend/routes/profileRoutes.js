const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/profileController');
const auth = require('../middleware/authMiddleware');
const multer = require('multer');
const path = require('path');

const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, 'uploads/'),
    filename: (req, file, cb) => cb(null, 'resume_' + Date.now() + path.extname(file.originalname))
});
const upload = multer({ storage });

router.get('/', ctrl.getProfile);
router.put('/', auth, ctrl.updateProfile);
router.patch('/resume', auth, upload.single('resume'), ctrl.uploadResume);
router.delete('/resume', auth, ctrl.deleteResume);
router.patch('/photo', auth, upload.single('photo'), ctrl.uploadPhoto);
router.delete('/photo', auth, ctrl.deletePhoto);

module.exports = router;

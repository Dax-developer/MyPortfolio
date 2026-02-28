const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/educationController');
const auth = require('../middleware/authMiddleware');
const multer = require('multer');
const path = require('path');

const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, 'uploads/'),
    filename: (req, file, cb) => cb(null, Date.now() + path.extname(file.originalname))
});
const upload = multer({ storage });

router.get('/', ctrl.getEducation);
router.post('/', auth, upload.single('certificate'), ctrl.createEducation);
router.get('/:id', ctrl.getEducationById);
router.put('/:id', auth, upload.single('certificate'), ctrl.updateEducation);
router.delete('/:id', auth, ctrl.deleteEducation);
router.patch('/:id/certificate', auth, upload.single('certificate'), ctrl.updateCertificate);
router.delete('/:id/certificate', auth, ctrl.deleteCertificate);

module.exports = router;

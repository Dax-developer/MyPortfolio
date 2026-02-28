const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/certificateController');
const auth = require('../middleware/authMiddleware');
const multer = require('multer');
const path = require('path');

const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, 'uploads/'),
    filename: (req, file, cb) => cb(null, 'cert_' + Date.now() + path.extname(file.originalname))
});
const upload = multer({ storage });

router.get('/', ctrl.getCertificates);
router.post('/', auth, upload.single('certificate'), ctrl.createCertificate);
router.delete('/bulk', auth, ctrl.deleteCertificatesBulk);
router.delete('/:id', auth, ctrl.deleteCertificate);

module.exports = router;

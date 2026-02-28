const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/authController');

router.post('/login', ctrl.login);
router.post('/signup', ctrl.signup);
router.post('/verify-otp', ctrl.verifyOtp);
router.post('/forgot-password', ctrl.forgotPassword);
router.post('/reset-password', ctrl.resetPassword);

// Admin Passcode Management
router.post('/admin/verify-passcode', ctrl.verifyAdminPasscode);
router.post('/admin/forgot-passcode', ctrl.forgotAdminPasscode);
router.post('/admin/reset-passcode', ctrl.resetAdminPasscode);

module.exports = router;

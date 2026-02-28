const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const User = require('../models/User');
const nodemailer = require('nodemailer');

// Email Transporter (using environment variables)
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
    }
});

exports.signup = async (req, res) => {
    try {
        const { email, password } = req.body;

        // Check if user exists
        let user = await User.findOne({ email });
        if (user) {
            return res.status(400).json({ error: 'User already exists' });
        }

        // Generate OTP
        const otp = Math.floor(100000 + Math.random() * 900000).toString();
        const otpExpires = Date.now() + 10 * 60 * 1000; // 10 minutes

        user = new User({
            email,
            password,
            otp,
            otpExpires
        });

        await user.save();

        // Send OTP via email
        const mailOptions = {
            from: process.env.EMAIL_USER,
            to: email,
            subject: 'Portfolio Signup OTP',
            text: `Your OTP for portfolio signup is: ${otp}. It expires in 10 minutes.`
        };

        if (process.env.EMAIL_USER && process.env.EMAIL_PASS) {
            await transporter.sendMail(mailOptions);
        } else {
            console.log('--- EMAIL CONFIG MISSING ---');
            console.log(`OTP for ${email}: ${otp}`);
        }

        res.json({ message: 'OTP sent to email' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.verifyOtp = async (req, res) => {
    try {
        const { email, otp } = req.body;
        const user = await User.findOne({
            email,
            otp,
            otpExpires: { $gt: Date.now() }
        });

        if (!user) {
            return res.status(400).json({ error: 'Invalid or expired OTP' });
        }

        user.isVerified = true;
        user.otp = undefined;
        user.otpExpires = undefined;
        await user.save();

        const token = jwt.sign({ id: user._id, isAdmin: true }, process.env.JWT_SECRET || 'secret_key', { expiresIn: '1d' });
        res.json({ token, message: 'Signup successful and verified' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};


exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;

        const user = await User.findOne({ email });
        if (!user) {
            return res.status(401).json({ error: 'Invalid email or password' });
        }

        if (!user.isVerified) {
            return res.status(403).json({ error: 'Email not verified' });
        }

        const isMatch = await user.comparePassword(password);
        if (!isMatch) {
            return res.status(401).json({ error: 'Invalid email or password' });
        }

        const token = jwt.sign({ id: user._id, isAdmin: true }, process.env.JWT_SECRET || 'secret_key', { expiresIn: '1d' });
        res.json({ token });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};
exports.forgotPassword = async (req, res) => {
    try {
        const { email } = req.body;
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }

        // Generate OTP
        const otp = Math.floor(100000 + Math.random() * 900000).toString();
        const otpExpires = Date.now() + 10 * 60 * 1000; // 10 minutes

        user.otp = otp;
        user.otpExpires = otpExpires;
        await user.save();

        // Send OTP via email
        const mailOptions = {
            from: process.env.EMAIL_USER,
            to: email,
            subject: 'Portfolio Password Reset OTP',
            text: `Your OTP for password reset is: ${otp}. It expires in 10 minutes.`
        };

        if (process.env.EMAIL_USER && process.env.EMAIL_PASS) {
            await transporter.sendMail(mailOptions);
        } else {
            console.log('--- EMAIL CONFIG MISSING ---');
            console.log(`Password Reset OTP for ${email}: ${otp}`);
        }

        res.json({ message: 'Reset OTP sent' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.resetPassword = async (req, res) => {
    try {
        const { email, otp, newPassword } = req.body;
        const user = await User.findOne({
            email,
            otp,
            otpExpires: { $gt: Date.now() }
        });

        if (!user) {
            return res.status(400).json({ error: 'Invalid or expired OTP' });
        }

        // Update password (User model should handle hashing in pre-save)
        user.password = newPassword;
        user.otp = undefined;
        user.otpExpires = undefined;
        await user.save();

        res.json({ message: 'Password reset successful' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.verifyAdminPasscode = async (req, res) => {
    try {
        const { passcode } = req.body;
        // Since there's only one user/admin for this portfolio, we just find any user
        const user = await User.findOne();
        if (!user) return res.status(404).json({ error: 'User not found' });

        if (user.adminPasscode === passcode) {
            res.json({ success: true });
        } else {
            res.status(401).json({ success: false, error: 'Incorrect passcode' });
        }
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.forgotAdminPasscode = async (req, res) => {
    try {
        // Hardcoded email for admin reset
        const adminEmail = 'daxpatel230005@gmail.com';
        const user = await User.findOne();
        if (!user) return res.status(404).json({ error: 'User not found' });

        const otp = Math.floor(100000 + Math.random() * 900000).toString();
        user.adminResetOtp = otp;
        user.adminResetOtpExpires = Date.now() + 10 * 60 * 1000; // 10 minutes
        await user.save();

        const mailOptions = {
            from: process.env.EMAIL_USER,
            to: adminEmail,
            subject: 'Portfolio Admin Passcode Reset OTP',
            text: `Your OTP for admin passcode reset is: ${otp}. It expires in 10 minutes.`
        };

        if (process.env.EMAIL_USER && process.env.EMAIL_PASS) {
            await transporter.sendMail(mailOptions);
        } else {
            console.log('--- ADMIN EMAIL CONFIG MISSING ---');
            console.log(`Admin OTP for ${adminEmail}: ${otp}`);
        }

        res.json({ message: 'OTP sent to daxpatel230005@gmail.com' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.resetAdminPasscode = async (req, res) => {
    try {
        const { otp, newPasscode } = req.body;
        const user = await User.findOne({
            adminResetOtp: otp,
            adminResetOtpExpires: { $gt: Date.now() }
        });

        if (!user) {
            return res.status(400).json({ error: 'Invalid or expired OTP' });
        }

        user.adminPasscode = newPasscode;
        user.adminResetOtp = undefined;
        user.adminResetOtpExpires = undefined;
        await user.save();

        res.json({ message: 'Admin passcode reset successful' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

const express = require('express');
const router = express.Router();
const reviewCtrl = require('../controllers/reviewController');
const analyticsCtrl = require('../controllers/analyticsController');

// Review Routes
router.get('/reviews', reviewCtrl.getReviews);
router.post('/reviews', reviewCtrl.addReview);

// Analytics Routes
router.get('/analytics', analyticsCtrl.getStats);

module.exports = router;

const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/experienceController');
const auth = require('../middleware/authMiddleware');

router.get('/', ctrl.getExperience);
router.post('/', auth, ctrl.createExperience);
router.get('/:id', ctrl.getExperienceById);
router.put('/:id', auth, ctrl.updateExperience);
router.delete('/:id', auth, ctrl.deleteExperience);

module.exports = router;

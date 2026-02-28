const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/skillController');
const auth = require('../middleware/authMiddleware');

router.get('/', ctrl.getSkills);
router.post('/', auth, ctrl.createSkill);
router.post('/bulk', auth, ctrl.createSkillsBulk);
router.delete('/bulk', auth, ctrl.deleteSkillsBulk);
router.delete('/:id', auth, ctrl.deleteSkill);
router.put('/:id', auth, ctrl.updateSkill);

module.exports = router;

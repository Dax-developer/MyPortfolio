const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/projectController');
const auth = require('../middleware/authMiddleware');

router.get('/', ctrl.getProjects);
router.post('/', auth, ctrl.createProject);
router.get('/:id', ctrl.getProjectById);
router.put('/:id', auth, ctrl.updateProject);
router.delete('/bulk', auth, ctrl.deleteProjectsBulk);
router.delete('/:id', auth, ctrl.deleteProject);

module.exports = router;

const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/languageController');

router.get('/', ctrl.getLanguages);
router.post('/', ctrl.addLanguage);
router.delete('/:id', ctrl.deleteLanguage);

module.exports = router;

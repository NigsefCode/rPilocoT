const express = require('express');
const router = express.Router();
const configController = require('../controllers/configController');
const { protect } = require('../middleware/authMiddleware');

router.get('/google-maps', protect, configController.getGoogleMapsConfig);

module.exports = router;
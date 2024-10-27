const express = require('express');
const { protect } = require('../middleware/authMiddleware');
const { 
  register, 
  login, 
  logout, 
  getProfile,
  updatePassword,
  updateName,
  updateQuestionnaireStatus 
} = require('../controllers/authController');

const router = express.Router();

// Asegúrate de que todos estos controladores existan en authController.js
router.post('/register', register);
router.post('/login', login);
router.post('/logout', logout);
router.get('/profile', protect, getProfile);
router.put('/update-password', protect, updatePassword);
router.put('/update-name', protect, updateName);
router.put('/questionnaire-status', protect, updateQuestionnaireStatus);

module.exports = router;
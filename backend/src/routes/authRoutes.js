const express = require('express');
const { protect } = require('../middleware/authMiddleware');
const {
  register,
  login,
  logout,
  getProfile,
  updatePassword,
  updateName,
  updateQuestionnaireStatus,
  registerGoogle, // Añadir el nuevo controlador de Google
} = require('../controllers/authController');

const router = express.Router();

// Rutas de autenticación
router.post('/register', register);
router.post('/login', login);
router.post('/logout', logout);
router.get('/profile', protect, getProfile);
router.put('/update-password', protect, updatePassword);
router.put('/update-name', protect, updateName);
router.put('/questionnaire-status', protect, updateQuestionnaireStatus);
router.post('/register-google', registerGoogle); // Nueva ruta para el registro de Google

module.exports = router;
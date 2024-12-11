const express = require('express');
const { protect, isAdmin } = require('../middleware/authMiddleware');
const { updateFuelPrice, getCurrentPrices } = require('../controllers/fuelPriceController');

const router = express.Router();

// Obtener precios actuales (todos los usuarios autenticados)
router.get('/', protect, getCurrentPrices);

// Actualizar precio de combustible (solo administradores)
router.post('/', protect, isAdmin, updateFuelPrice);

module.exports = router;
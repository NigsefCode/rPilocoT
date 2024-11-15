// routes/routeRoutes.js
const express = require('express');
const router = express.Router();
const routeController = require('../controllers/routeController');
const fuelPriceController = require('../controllers/fuelPriceController');
const { protect, isAdmin } = require('../middleware/authMiddleware');

// Rutas públicas (sin autenticación)
router.get('/fuel-prices', fuelPriceController.getCurrentPrices);

// Aplicar middleware de autenticación al resto de rutas
router.use(protect);

// Rutas protegidas (requieren autenticación)
router.post('/calculate', routeController.calculateRoute);
router.get('/history', routeController.getRouteHistory);
router.get('/:id', routeController.getRouteById);

// Rutas que requieren ser admin
router.put('/fuel-prices', isAdmin, fuelPriceController.updateFuelPrice);

module.exports = router;
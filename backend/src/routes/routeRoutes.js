// routes/routeRoutes.js
const express = require('express');
const router = express.Router();
const routeController = require('../controllers/routeController');
const fuelPriceController = require('../controllers/fuelPriceController');
const { protect, isAdmin } = require('../middleware/authMiddleware');

// Rutas públicas
router.get('/fuel-prices', fuelPriceController.getCurrentPrices);
router.get('/destinations', routeController.getAvailableDestinations);

// Rutas protegidas
router.use(protect);
router.post('/calculate', routeController.calculateRoute);
router.get('/history', routeController.getRouteHistory);
router.get('/:id', routeController.getRouteById);
router.put('/:id/cancel', routeController.cancelRoute);
router.put('/:id/complete', routeController.completeRoute);
router.get('/stats/user', routeController.getUserRouteStats);

// Rutas admin
router.use(isAdmin);
router.put('/fuel-prices', fuelPriceController.updateFuelPrice);
router.get('/stats/global', routeController.getGlobalRouteStats);
router.get('/active-routes', routeController.getActiveRoutes);

module.exports = router;
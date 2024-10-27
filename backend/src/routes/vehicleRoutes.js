const express = require('express');
const { protect } = require('../middleware/authMiddleware');
const {
  getUserVehicles,
  getVehicle,
  createVehicle,
  updateVehicle,
  deleteVehicle
} = require('../controllers/vehicleController');

const router = express.Router();

// Todas las rutas requieren autenticación
router.use(protect);

// Rutas para vehículos
router.route('/')
  .get(getUserVehicles)
  .post(createVehicle);

router.route('/:id')
  .get(getVehicle)
  .put(updateVehicle)
  .delete(deleteVehicle);

module.exports = router;
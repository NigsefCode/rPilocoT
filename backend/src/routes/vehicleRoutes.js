const express = require('express');
const { protect } = require('../middleware/authMiddleware');
const {
  getUserVehicles,
  getVehicle,
  createVehicle,
  updateVehicle,
  deleteVehicle,
  getDefaultVehicle  // Agregamos el nuevo método
} = require('../controllers/vehicleController');

const router = express.Router();

// Todas las rutas requieren autenticación
router.use(protect);

// Ruta para obtener el vehículo por defecto (debe ir antes de /:id)
router.get('/default', getDefaultVehicle);

// Rutas para vehículos
router.route('/')
  .get(getUserVehicles)
  .post(createVehicle);

router.route('/:id')
  .get(getVehicle)
  .put(updateVehicle)
  .delete(deleteVehicle);

module.exports = router;
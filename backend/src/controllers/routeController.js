// controllers/routeController.js
const Route = require('../models/Route');
const Vehicle = require('../models/Vehicle');
const HybridRouteService = require('../services/HybridRouteService');

const routeController = {
  calculateRoute: async (req, res) => {
    try {
      const { destination, vehicleId, routeType } = req.body;
      
      console.log('Datos recibidos:', { destination, vehicleId, routeType });
      
      if (!destination || !vehicleId) {
        return res.status(400).json({
          message: 'Faltan datos necesarios para calcular la ruta'
        });
      }

      // Normalizar el nombre del destino
      const normalizedDestination = destination.toUpperCase();

      // Verificar que el destino es válido
      if (!['PICHILEMU', 'ILOCA', 'CONSTITUCION'].includes(normalizedDestination)) {
        return res.status(400).json({
          message: `Destino no válido. Opciones válidas: PICHILEMU, ILOCA, CONSTITUCION. Recibido: ${normalizedDestination}`
        });
      }

      const vehicle = await Vehicle.findById(vehicleId);
      if (!vehicle) {
        return res.status(404).json({
          message: 'Vehículo no encontrado'
        });
      }

      console.log('Calculando ruta para:', normalizedDestination);
      
      const routeData = await HybridRouteService.calculateRoute(
        normalizedDestination,
        vehicle,
        new Date()
      );

      console.log('Ruta calculada:', routeData);

      const newRoute = new Route({
        userId: req.user.id,
        vehicleId,
        origin: routeData.origin,
        destination: routeData.destination,
        distance: routeData.distance,
        duration: routeData.duration,
        fuelConsumption: routeData.fuelConsumption,
        estimatedCost: routeData.estimatedCost,
        trafficMultiplier: routeData.trafficMultiplier,
        routeType: routeType || 'optimal'
      });

      await newRoute.save();

      res.json({
        ...routeData,
        vehicle: {
          brand: vehicle.brand,
          model: vehicle.model,
          engineType: vehicle.engineType
        }
      });

    } catch (error) {
      console.error('Error al calcular ruta:', error);
      res.status(500).json({
        message: 'Error al calcular la ruta',
        error: error.message
      });
    }
  },

  getRouteHistory: async (req, res) => {
    try {
      const routes = await Route.find({ userId: req.user.id })
        .populate('vehicleId')
        .sort({ createdAt: -1 });

      res.json(routes);
    } catch (error) {
      res.status(500).json({
        message: 'Error al obtener historial de rutas',
        error: error.message
      });
    }
  },

  getRouteById: async (req, res) => {
    try {
      const route = await Route.findOne({
        _id: req.params.id,
        userId: req.user.id
      }).populate('vehicleId');

      if (!route) {
        return res.status(404).json({
          message: 'Ruta no encontrada'
        });
      }

      res.json(route);
    } catch (error) {
      res.status(500).json({
        message: 'Error al obtener la ruta',
        error: error.message
      });
    }
  },

  getFuelPrices: async (req, res) => {
    try {
      // En el futuro podrías obtener esto de la base de datos
      res.json({
        Bencina: 1200,
        Petróleo: 1000
      });
    } catch (error) {
      res.status(500).json({
        message: 'Error al obtener precios de combustible',
        error: error.message
      });
    }
  }
};

module.exports = routeController;
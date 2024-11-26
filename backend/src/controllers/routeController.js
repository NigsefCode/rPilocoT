// controllers/routeController.js
const Route = require('../models/Route');
const Vehicle = require('../models/Vehicle');
const { googleMapsClient, calculateFuelConsumption } = require('../config/googleMaps');
const mongoose = require('mongoose');

const routeController = {
  // Obtener destinos disponibles
  getAvailableDestinations: async (req, res) => {
    try {
      const destinations = [
        {
          id: 'pichilemu',
          name: 'Pichilemu',
          coordinates: { lat: -34.3873, lng: -72.0034 },
          description: 'Conocida por sus playas para el surf',
          distanceFromTalca: 238
        },
        {
          id: 'iloca',
          name: 'Iloca',
          coordinates: { lat: -34.9307, lng: -72.1791 },
          description: 'Playa familiar con aguas tranquilas',
          distanceFromTalca: 147
        },
        {
          id: 'constitucion',
          name: 'Constitución',
          coordinates: { lat: -35.3330, lng: -72.4167 },
          description: 'Ciudad costera con hermosas vistas',
          distanceFromTalca: 111
        }
      ];
      
      res.json(destinations);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  },

  // Calcular ruta
calculateRoute: async (req, res) => {
  try {
    console.log('Iniciando cálculo de ruta...'); // Debug
    const { origin, destinationId, vehicleId, routeType } = req.body;
    const userId = req.user.id;

    // Validar vehículo
    const vehicle = await Vehicle.findById(vehicleId);
    if (!vehicle) {
      console.log('Vehículo no encontrado:', vehicleId); // Debug
      return res.status(404).json({ message: 'Vehículo no encontrado' });
    }

    // Obtener precio actual del combustible
    const fuelPrice = await mongoose.model('FuelPrice').findOne({
      fuelType: vehicle.engineType
    }).sort({ createdAt: -1 });

    if (!fuelPrice) {
      console.log('No se encontraron precios de combustible para:', vehicle.engineType); // Debug
      return res.status(400).json({ message: 'No hay precios de combustible disponibles' });
    }

    // Validar y obtener destino
    const destinations = [
      {
        id: 'pichilemu',
        coordinates: { lat: -34.3873, lng: -72.0034 },
        name: 'Pichilemu',
        distanceFromTalca: 238
      },
      {
        id: 'iloca',
        coordinates: { lat: -34.9307, lng: -72.1791 },
        name: 'Iloca',
        distanceFromTalca: 147
      },
      {
        id: 'constitucion',
        coordinates: { lat: -35.3330, lng: -72.4167 },
        name: 'Constitución',
        distanceFromTalca: 111
      }
    ];

    const destination = destinations.find(d => d.id === destinationId);
    if (!destination) {
      console.log('Destino no válido:', destinationId); // Debug
      return res.status(404).json({ message: 'Destino no válido' });
    }

    console.log('Consultando Google Maps API...'); // Debug
    // Obtener ruta de Google Maps
    const response = await googleMapsClient.directions({
      params: {
        origin: `${origin.lat},${origin.lng}`,
        destination: `${destination.coordinates.lat},${destination.coordinates.lng}`,
        mode: 'driving',
        optimize_waypoints: routeType === 'optimal',
        alternatives: true,
        key: process.env.GOOGLE_MAPS_API_KEY
      }
    });

    if (!response.data.routes || response.data.routes.length === 0) {
      console.log('No se encontraron rutas en Google Maps'); // Debug
      return res.status(400).json({ message: 'No se pudo calcular la ruta' });
    }

    const route = response.data.routes[0];
    const distance = route.legs[0].distance.value / 1000; // Convertir a kilómetros
    const duration = route.legs[0].duration.value / 60; // Convertir a minutos

    // Calcular nivel de tráfico y consumo de combustible
    const trafficLevel = getCurrentTrafficLevel();
    const fuelConsumption = calculateFuelConsumption(distance, vehicle, trafficLevel);
    
    // Calcular costo estimado
    const estimatedCost = fuelConsumption * fuelPrice.price;

    console.log('Creando nueva ruta...'); // Debug
    // Crear nueva ruta
    const newRoute = new Route({
      userId,
      vehicleId,
      origin: {
        lat: origin.lat,
        lng: origin.lng,
        name: origin.name || 'Origen'
      },
      destination: {
        lat: destination.coordinates.lat,
        lng: destination.coordinates.lng,
        name: destination.name
      },
      distance,
      duration,
      fuelConsumption,
      routeType,
      polyline: route.overview_polyline.points || '', // Asegurar que no sea null
      trafficLevel,
      estimatedCost,
      status: 'active'
    });

    await newRoute.save();
    console.log('Ruta guardada exitosamente'); // Debug

    // Preparar respuesta
    const responseData = {
      route: {
        ...newRoute.toObject(),
        // Asegurar que estos campos estén presentes y formateados correctamente
        _id: newRoute._id.toString(),
        userId: newRoute.userId.toString(),
        vehicleId: newRoute.vehicleId.toString(),
        polyline: newRoute.polyline,
        createdAt: newRoute.createdAt,
        updatedAt: newRoute.updatedAt
      },
      trafficInfo: {
        level: trafficLevel,
        description: getTrafficDescription(trafficLevel)
      },
      fuelInfo: {
        consumption: fuelConsumption,
        engineType: vehicle.engineType,
        fuelPrice: fuelPrice.price,
        estimatedCost
      }
    };

    console.log('Enviando respuesta...'); // Debug
    res.json(responseData);
  } catch (error) {
    console.error('Error detallado en calculateRoute:', error); // Debug
    console.error('Stack trace:', error.stack); // Debug
    res.status(500).json({ 
      message: 'Error al calcular la ruta',
      error: error.message,
      stack: process.env.NODE_ENV === 'development' ? error.stack : undefined
    });
  }
},

  // Obtener historial de rutas
  getRouteHistory: async (req, res) => {
    try {
      const userId = req.user.id;
      const routes = await Route.find({ userId })
        .populate('vehicleId')
        .sort({ createdAt: -1 });
      
      res.json(routes);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  },

  // Obtener una ruta específica
  getRouteById: async (req, res) => {
    try {
      const route = await Route.findById(req.params.id)
        .populate('vehicleId')
        .populate('userId', 'name email');

      if (!route) {
        return res.status(404).json({ message: 'Ruta no encontrada' });
      }

      res.json(route);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  },

  // Cancelar una ruta
  cancelRoute: async (req, res) => {
    try {
      const route = await Route.findById(req.params.id);
      
      if (!route) {
        return res.status(404).json({ message: 'Ruta no encontrada' });
      }
      
      if (route.userId.toString() !== req.user.id) {
        return res.status(403).json({ message: 'No autorizado' });
      }
      
      route.status = 'cancelled';
      await route.save();
      
      res.json(route);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  },

  // Completar una ruta
  completeRoute: async (req, res) => {
    try {
      const route = await Route.findById(req.params.id);
      
      if (!route) {
        return res.status(404).json({ message: 'Ruta no encontrada' });
      }
      
      if (route.userId.toString() !== req.user.id) {
        return res.status(403).json({ message: 'No autorizado' });
      }
      
      route.status = 'completed';
      await route.save();
      
      res.json(route);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  },

  // Obtener estadísticas de usuario
  getUserRouteStats: async (req, res) => {
    try {
      const stats = await Route.aggregate([
        { 
          $match: { 
            userId: mongoose.Types.ObjectId(req.user.id) 
          } 
        },
        { 
          $group: {
            _id: null,
            totalRoutes: { $sum: 1 },
            totalDistance: { $sum: '$distance' },
            totalFuelConsumption: { $sum: '$fuelConsumption' },
            averageCost: { $avg: '$estimatedCost' },
            routesByType: {
              $push: {
                routeType: '$routeType',
                distance: '$distance',
                fuelConsumption: '$fuelConsumption'
              }
            }
          }
        }
      ]);
      
      res.json(stats[0] || {
        totalRoutes: 0,
        totalDistance: 0,
        totalFuelConsumption: 0,
        averageCost: 0,
        routesByType: []
      });
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  },

  // Obtener estadísticas globales (admin)
  getGlobalRouteStats: async (req, res) => {
    try {
      const stats = await Route.aggregate([
        { 
          $group: {
            _id: null,
            totalRoutes: { $sum: 1 },
            activeRoutes: {
              $sum: { $cond: [{ $eq: ['$status', 'active'] }, 1, 0] }
            },
            completedRoutes: {
              $sum: { $cond: [{ $eq: ['$status', 'completed'] }, 1, 0] }
            },
            totalDistance: { $sum: '$distance' },
            totalFuelConsumption: { $sum: '$fuelConsumption' },
            averageCost: { $avg: '$estimatedCost' }
          }
        }
      ]);
      
      res.json(stats[0] || {
        totalRoutes: 0,
        activeRoutes: 0,
        completedRoutes: 0,
        totalDistance: 0,
        totalFuelConsumption: 0,
        averageCost: 0
      });
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  },

  // Obtener rutas activas (admin)
  getActiveRoutes: async (req, res) => {
    try {
      const activeRoutes = await Route.find({ status: 'active' })
        .populate('userId', 'name email')
        .populate('vehicleId')
        .sort({ createdAt: -1 });
      
      res.json(activeRoutes);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  }
};

// Funciones auxiliares
function getCurrentTrafficLevel() {
  const hour = new Date().getHours();
  
  if ((hour >= 7 && hour <= 9) || (hour >= 17 && hour <= 19)) {
    return 'high';
  }
  else if (hour > 9 && hour < 17) {
    return 'medium';
  }
  return 'low';
}

function getTrafficDescription(level) {
  const descriptions = {
    low: 'Tráfico ligero, condiciones óptimas para viajar',
    medium: 'Tráfico moderado, tiempo de viaje normal',
    high: 'Tráfico pesado, espere demoras'
  };
  return descriptions[level] || 'Información de tráfico no disponible';
}

module.exports = routeController;
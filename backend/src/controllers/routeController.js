const Route = require('../models/Route');
const Vehicle = require('../models/Vehicle');
const { 
  googleMapsClient, 
  calculateFuelConsumption,
  getRouteOptions,
  selectBestRoute 
} = require('../config/googleMaps');
const mongoose = require('mongoose');

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

const routeController = {
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

  calculateRoute: async (req, res) => {
    try {
      console.log('Iniciando cálculo de ruta...'); // Debug
      const { origin, destinationId, vehicleId, routeType } = req.body;
      const userId = req.user.id;

      // Validar datos de entrada
      if (!origin?.lat || !origin?.lng || !destinationId || !vehicleId || !routeType) {
        return res.status(400).json({ 
          message: 'Datos de entrada incompletos',
          received: { origin, destinationId, vehicleId, routeType }
        });
      }

      // Validar vehículo
      const vehicle = await Vehicle.findById(vehicleId);
      if (!vehicle) {
        console.log('Vehículo no encontrado:', vehicleId);
        return res.status(404).json({ message: 'Vehículo no encontrado' });
      }

      // Obtener precio actual del combustible
      const fuelPrice = await mongoose.model('FuelPrice').findOne({
        fuelType: vehicle.engineType
      }).sort({ createdAt: -1 });

      if (!fuelPrice) {
        console.log('No se encontraron precios de combustible para:', vehicle.engineType);
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
        console.log('Destino no válido:', destinationId);
        return res.status(404).json({ message: 'Destino no válido' });
      }

      try {
        console.log('Obteniendo opciones de ruta...'); // Debug
        const routeOptions = getRouteOptions(origin, destination, routeType);
        
        console.log('Consultando Google Maps API...'); // Debug
        const response = await googleMapsClient.directions({
          params: {
            ...routeOptions,
            key: process.env.GOOGLE_MAPS_API_KEY
          }
        });

        if (!response.data?.routes?.length) {
          console.log('No se encontraron rutas disponibles');
          return res.status(400).json({ message: 'No se encontraron rutas disponibles' });
        }

        const selectedRoute = selectBestRoute(response.data.routes, routeType);
        if (!selectedRoute) {
          return res.status(400).json({ message: 'No se pudo seleccionar una ruta óptima' });
        }

        const distance = selectedRoute.legs[0].distance.value / 1000; // Convertir a kilómetros
        const duration = selectedRoute.legs[0].duration.value / 60; // Convertir a minutos
        const trafficLevel = getCurrentTrafficLevel();
        const fuelConsumption = calculateFuelConsumption(
          distance,
          vehicle,
          trafficLevel,
          routeType
        );

        const estimatedCost = fuelConsumption * fuelPrice.price;

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
          polyline: selectedRoute.overview_polyline.points || '',
          trafficLevel,
          estimatedCost,
          status: 'active'
        });

        await newRoute.save();

        const responseData = {
          route: {
            ...newRoute.toObject(),
            _id: newRoute._id.toString(),
            userId: newRoute.userId.toString(),
            vehicleId: newRoute.vehicleId.toString()
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

        res.json(responseData);

      } catch (googleError) {
        console.error('Error en la llamada a Google Maps:', googleError);
        return res.status(400).json({
          message: 'Error al consultar el servicio de rutas',
          error: googleError.message
        });
      }

    } catch (error) {
      console.error('Error en calculateRoute:', error);
      res.status(500).json({ 
        message: 'Error al calcular la ruta',
        error: error.message
      });
    }
  },

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

module.exports = routeController;
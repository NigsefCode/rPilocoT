// services/HybridRouteService.js
const moment = require('moment');
const { Client } = require('@googlemaps/google-maps-services-js');

const googleMapsClient = new Client({});

class HybridRouteService {
  // ... resto del código igual ...

  static async getGoogleMapsRoute(origin, destination, waypoints) {
    try {
      console.log('Intentando obtener ruta de Google Maps con:', {
        origin: origin.location,
        destination: `${destination.name}, Chile`,
        waypoints
      });

      const response = await googleMapsClient.directions({
        params: {
          origin: origin.location,
          destination: `${destination.name}, Chile`,
          waypoints: waypoints,
          optimize: true,
          mode: 'driving',
          region: 'cl',
          language: 'es',
          key: process.env.GOOGLE_MAPS_API_KEY,
        }
      });

      if (response.data.status !== 'OK') {
        throw new Error(`Error en Google Maps API: ${response.data.status}`);
      }

      return response.data.routes[0];
    } catch (error) {
      console.error('Error al obtener ruta de Google Maps:', error);
      
      // Retornar una ruta predefinida como fallback
      return this.getFallbackRoute(origin, destination);
    }
  }

  static getFallbackRoute(origin, destination) {
    // Crear un polyline simple entre origen y destino
    const bounds = {
      southwest: {
        lat: Math.min(origin.lat, destination.lat) - 0.1,
        lng: Math.min(origin.lng, destination.lng) - 0.1
      },
      northeast: {
        lat: Math.max(origin.lat, destination.lat) + 0.1,
        lng: Math.max(origin.lng, destination.lng) + 0.1
      }
    };

    return {
      legs: [{
        distance: { value: DESTINATIONS[destination.name].baseDistance * 1000 },
        duration: { value: (DESTINATIONS[destination.name].baseDistance / 60) * 3600 }
      }],
      overview_polyline: {
        points: this.generateSimplePolyline(origin, destination)
      },
      bounds: bounds
    };
  }

  static generateSimplePolyline(origin, destination) {
    // Generar un polyline simple (línea recta entre origen y destino)
    return `${origin.lat},${origin.lng}|${destination.lat},${destination.lng}`;
  }

  static async calculateRoute(destinationName, vehicle, date = new Date()) {
    try {
      const destination = DESTINATIONS[destinationName];
      if (!destination) {
        throw new Error(`Destino no válido. Opciones: ${Object.keys(DESTINATIONS).join(', ')}`);
      }

      // Calcular factores de tráfico y consumo
      const trafficMultiplier = this.calculateTrafficMultiplier(destination, date);
      const fuelConsumption = this.calculateFuelConsumption(
        destination.baseDistance,
        vehicle,
        trafficMultiplier
      );

      // Intentar obtener la ruta de Google Maps o usar fallback
      let mapData;
      try {
        const googleRoute = await this.getGoogleMapsRoute(
          TALCA_ORIGIN,
          destination,
          destination.waypoints
        );
        mapData = {
          polyline: googleRoute.overview_polyline.points,
          bounds: googleRoute.bounds,
          legs: googleRoute.legs
        };
      } catch (error) {
        console.log('Usando ruta predefinida debido a error:', error);
        const fallbackRoute = this.getFallbackRoute(TALCA_ORIGIN, destination);
        mapData = {
          polyline: fallbackRoute.overview_polyline.points,
          bounds: fallbackRoute.bounds,
          legs: fallbackRoute.legs
        };
      }

      return {
        origin: TALCA_ORIGIN,
        destination: {
          name: destination.name,
          lat: destination.lat,
          lng: destination.lng
        },
        distance: destination.baseDistance,
        duration: Math.round((destination.baseDistance / 75) * trafficMultiplier * 60),
        fuelConsumption: Number(fuelConsumption.toFixed(2)),
        trafficMultiplier: Number(trafficMultiplier.toFixed(2)),
        estimatedCost: Math.round(fuelConsumption * (vehicle.engineType === 'Bencina' ? 1200 : 1000)),
        routeDetails: destination.routeDetails,
        tips: this.generateTips(destination, date),
        mapData
      };
    } catch (error) {
      console.error('Error en calculateRoute:', error);
      throw error;
    }
  }
}

module.exports = HybridRouteService;
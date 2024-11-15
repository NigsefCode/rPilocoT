// services/FixedRouteService.js
const moment = require('moment');

const DESTINATIONS = {
  ILOCA: {
    name: 'Iloca',
    lat: -34.9307,
    lng: -72.1791,
    baseDistance: 108,
    routeDetails: {
      stops: ['Duao'],
      roadType: 'Pavimentada',
      difficulty: 'Media'
    },
    trafficPatterns: {
      weekday: {
        morning: 1.0,
        afternoon: 1.2,
        evening: 1.1
      },
      weekend: {
        morning: 1.3,
        afternoon: 1.5,
        evening: 1.2
      },
      summer: 1.4,
      winter: 1.0
    }
  },
  PICHILEMU: {
    name: 'Pichilemu',
    lat: -34.3867,
    lng: -72.0033,
    baseDistance: 198,
    routeDetails: {
      stops: ['Santa Cruz', 'Lolol'],
      roadType: 'Pavimentada',
      difficulty: 'Alta'
    },
    trafficPatterns: {
      weekday: {
        morning: 1.0,
        afternoon: 1.2,
        evening: 1.1
      },
      weekend: {
        morning: 1.4,
        afternoon: 1.6,
        evening: 1.3
      },
      summer: 1.5,
      winter: 1.0
    }
  },
  CONSTITUCION: {
    name: 'Constitución',
    lat: -35.3332,
    lng: -72.4167,
    baseDistance: 111,
    routeDetails: {
      stops: ['Maule'],
      roadType: 'Pavimentada',
      difficulty: 'Baja'
    },
    trafficPatterns: {
      weekday: {
        morning: 1.0,
        afternoon: 1.1,
        evening: 1.0
      },
      weekend: {
        morning: 1.2,
        afternoon: 1.4,
        evening: 1.1
      },
      summer: 1.3,
      winter: 1.0
    }
  }
};

const TALCA_ORIGIN = {
  lat: -35.4272,
  lng: -71.6554,
  name: 'Talca'
};

class FixedRouteService {
  static getTimeOfDay(hour) {
    if (hour >= 6 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 18) return 'afternoon';
    return 'evening';
  }

  static calculateTrafficMultiplier(destination, date) {
    const momentDate = moment(date);
    const isWeekend = momentDate.day() === 0 || momentDate.day() === 6;
    const isSummer = momentDate.month() >= 11 || momentDate.month() <= 2;
    const timeOfDay = this.getTimeOfDay(momentDate.hour());

    const dayType = isWeekend ? 'weekend' : 'weekday';
    const seasonMultiplier = isSummer ? destination.trafficPatterns.summer : destination.trafficPatterns.winter;
    const timeMultiplier = destination.trafficPatterns[dayType][timeOfDay];

    return seasonMultiplier * timeMultiplier;
  }

  static calculateFuelConsumption(distance, vehicle, trafficMultiplier) {
    const baseConsumption = {
      'Bencina': 8.5,
      'Petróleo': 6.5
    };

    return (distance / 100) * baseConsumption[vehicle.engineType] * trafficMultiplier;
  }

  static generateTips(destination, date) {
    const tips = [];
    const momentDate = moment(date);
    const isSummer = momentDate.month() >= 11 || momentDate.month() <= 2;
    const isWeekend = momentDate.day() === 0 || momentDate.day() === 6;

    if (isSummer && isWeekend) {
      tips.push('Se recomienda salir temprano para evitar congestión');
    }

    if (destination.routeDetails.difficulty === 'Alta') {
      tips.push('Ruta con curvas pronunciadas. Conducir con precaución');
    }

    if (destination.routeDetails.stops.length > 0) {
      tips.push(`Paradas recomendadas: ${destination.routeDetails.stops.join(', ')}`);
    }

    return tips;
  }

  static async calculateRoute(destinationName, vehicle, date = new Date()) {
    const destination = DESTINATIONS[destinationName.toUpperCase()];
    if (!destination) {
      throw new Error(`Destino no válido. Opciones: ${Object.keys(DESTINATIONS).join(', ')}`);
    }

    const trafficMultiplier = this.calculateTrafficMultiplier(destination, date);
    const fuelConsumption = this.calculateFuelConsumption(
      destination.baseDistance,
      vehicle,
      trafficMultiplier
    );

    // Velocidad promedio base: 75 km/h
    const duration = Math.round((destination.baseDistance / 75) * trafficMultiplier * 60);

    return {
      origin: TALCA_ORIGIN,
      destination: {
        name: destination.name,
        lat: destination.lat,
        lng: destination.lng
      },
      distance: destination.baseDistance,
      duration,
      fuelConsumption: Number(fuelConsumption.toFixed(2)),
      trafficMultiplier: Number(trafficMultiplier.toFixed(2)),
      estimatedCost: Math.round(fuelConsumption * (vehicle.engineType === 'Bencina' ? 1200 : 1000)),
      routeDetails: destination.routeDetails,
      tips: this.generateTips(destination, date)
    };
  }
}

module.exports = FixedRouteService;
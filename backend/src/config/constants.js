// config/constants.js
module.exports = {
    DESTINATIONS: [
      {
        id: 'pichilemu',
        name: 'Pichilemu',
        coordinates: { lat: -34.3873, lng: -72.0034 },
        description: 'Conocida por sus playas para el surf',
        distanceFromTalca: 238 // en kilómetros
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
    ],
    TRAFFIC_LEVELS: {
      LOW: 'low',
      MEDIUM: 'medium',
      HIGH: 'high'
    },
    ROUTE_TYPES: {
      OPTIMAL: 'optimal',
      FASTEST: 'fastest'
    },
    FUEL_TYPES: {
      GASOLINE: 'Bencina',
      DIESEL: 'Petróleo'
    }
  };
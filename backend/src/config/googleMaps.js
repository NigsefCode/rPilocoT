const { Client } = require('@googlemaps/google-maps-services-js');

const googleMapsClient = new Client({});

const calculateFuelConsumption = (distance, vehicle, trafficLevel, routeType) => {
  // Factores base de consumo por tipo de motor (L/100km)
  const baseConsumption = {
    'Bencina': 8.5,
    'Petróleo': 6.5
  };

  // Factores de ajuste por tráfico
  const trafficFactor = {
    'low': 1,
    'medium': 1.2,
    'high': 1.4
  };

  // Factores de ajuste por tipo de ruta
  const routeFactor = routeType === 'optimal' ? 0.85 : 1.15;

  // Cálculo básico del consumo
  const baseConsumptionRate = baseConsumption[vehicle.engineType];
  const adjustedConsumption = baseConsumptionRate * trafficFactor[trafficLevel] * routeFactor;
  
  // Consumo total en litros
  return (distance / 100) * adjustedConsumption;
};

// Opciones de ruta según el tipo
const getRouteOptions = (origin, destination, routeType) => {
  // Obtener timestamp actual
  const now = new Date();
  
  // Configuración base
  const baseOptions = {
    origin: `${origin.lat},${origin.lng}`,
    destination: `${destination.coordinates.lat},${destination.coordinates.lng}`,
    mode: 'driving',
    alternatives: true,
    departure_time: now
  };

  switch (routeType) {
    case 'optimal':
      return {
        ...baseOptions,
        traffic_model: 'best_guess'
      };
    case 'economic':
      return {
        ...baseOptions,
        avoid: ['tolls', 'highways'],
        traffic_model: 'pessimistic'
      };
    case 'fast':
      return {
        ...baseOptions,
        traffic_model: 'optimistic'
      };
    default:
      return baseOptions;
  }
};

// Seleccionar la mejor ruta según el tipo
const selectBestRoute = (routes, routeType) => {
  if (!routes || routes.length === 0) return null;

  // Función para calcular el score de una ruta
  const calculateRouteScore = (route, routeType) => {
    const distance = route.legs[0].distance.value; // en metros
    const duration = route.legs[0].duration_in_traffic 
      ? route.legs[0].duration_in_traffic.value 
      : route.legs[0].duration.value; // en segundos
    
    switch (routeType) {
      case 'optimal':
        return (distance * 0.4) + (duration * 0.6);
      case 'economic':
        return (distance * 0.7) + (duration * 0.3);
      case 'fast':
        return (distance * 0.2) + (duration * 0.8);
      default:
        return distance + duration;
    }
  };

  // Ajustar los tiempos según el tipo de ruta
  const adjustDuration = (duration, routeType) => {
    const factors = {
      'optimal': 1.1,  // +10% del tiempo estimado
      'economic': 1.25, // +25% del tiempo estimado
      'fast': 0.9      // -10% del tiempo estimado
    };
    return Math.round(duration * (factors[routeType] || 1));
  };

  // Seleccionar la mejor ruta
  const selectedRoute = routes.reduce((prev, current) => {
    const prevScore = calculateRouteScore(prev, routeType);
    const currentScore = calculateRouteScore(current, routeType);
    return prevScore < currentScore ? prev : current;
  });

  // Ajustar el tiempo de la ruta seleccionada
  if (selectedRoute && selectedRoute.legs && selectedRoute.legs[0]) {
    const originalDuration = selectedRoute.legs[0].duration.value;
    selectedRoute.legs[0].duration.value = adjustDuration(originalDuration, routeType);
    
    if (selectedRoute.legs[0].duration_in_traffic) {
      const originalTrafficDuration = selectedRoute.legs[0].duration_in_traffic.value;
      selectedRoute.legs[0].duration_in_traffic.value = adjustDuration(originalTrafficDuration, routeType);
    }
  }

  return selectedRoute;
};

module.exports = {
  googleMapsClient,
  calculateFuelConsumption,
  getRouteOptions,
  selectBestRoute
};
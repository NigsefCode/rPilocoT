// config/googleMaps.js
const { Client } = require('@googlemaps/google-maps-services-js');

const googleMapsClient = new Client({});

const calculateFuelConsumption = (distance, vehicle, trafficLevel) => {
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

  // Cálculo básico del consumo
  const baseConsumptionRate = baseConsumption[vehicle.engineType];
  const adjustedConsumption = baseConsumptionRate * trafficFactor[trafficLevel];
  
  // Consumo total en litros
  return (distance / 100) * adjustedConsumption;
};

module.exports = {
  googleMapsClient,
  calculateFuelConsumption
};
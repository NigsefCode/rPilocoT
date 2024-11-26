// services/routeService.js
const axios = require('axios');

class RouteService {
  constructor() {
    this.weatherApiKey = process.env.WEATHER_API_KEY;
    this.googleMapsApiKey = process.env.GOOGLE_MAPS_API_KEY;
  }

  async getWeatherForLocation(lat, lng) {
    try {
      const response = await axios.get(
        `https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lng}&appid=${this.weatherApiKey}&units=metric`
      );
      return {
        condition: response.data.weather[0].main,
        temperature: response.data.main.temp,
        updatedAt: new Date()
      };
    } catch (error) {
      console.error('Error obteniendo el clima:', error);
      return null;
    }
  }

  calculateOptimalRoute(origin, destination, vehicleType, trafficLevel) {
    // Lógica para calcular la ruta más eficiente en términos de consumo
    const baseConsumption = this.getBaseConsumption(vehicleType);
    const trafficFactor = this.getTrafficFactor(trafficLevel);
    
    return {
      baseConsumption,
      adjustedConsumption: baseConsumption * trafficFactor
    };
  }

  getBaseConsumption(vehicleType) {
    const consumptionRates = {
      'Bencina': 8.5,
      'Petróleo': 6.5
    };
    return consumptionRates[vehicleType] || 8.5;
  }

  getTrafficFactor(trafficLevel) {
    const factors = {
      'low': 1,
      'medium': 1.2,
      'high': 1.4
    };
    return factors[trafficLevel] || 1.2;
  }
}

module.exports = new RouteService();
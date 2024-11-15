const tf = require('@tensorflow/tfjs-node');
const moment = require('moment');

class TrafficPredictionService {
  constructor() {
    this.model = null;
    this.initialized = false;
  }

  async initialize() {
    try {
      // Cargar modelo pre-entrenado
      this.model = await tf.loadLayersModel('file://./models/traffic_model/model.json');
      this.initialized = true;
    } catch (error) {
      console.error('Error al cargar modelo:', error);
      throw error;
    }
  }

  preprocessInput(routeData, timeData) {
    // Normalizar características
    const distance = routeData.distance / 100;
    const hour = timeData.hour() / 24;
    const dayOfWeek = timeData.day() / 7;
    const month = timeData.month() / 12;

    return tf.tensor2d([[
      distance,
      hour,
      dayOfWeek,
      month,
      routeData.historicalCongestion || 0.5,
      routeData.weatherCondition || 0.5,
      routeData.eventImpact || 0
    ]]);
  }

  async predictTrafficLevel(routeData) {
    if (!this.initialized) {
      await this.initialize();
    }

    const currentTime = moment();
    const input = this.preprocessInput(routeData, currentTime);
    
    const prediction = this.model.predict(input);
    const trafficScore = prediction.dataSync()[0];

    // Convertir score a nivel de tráfico
    if (trafficScore < 0.3) return 'low';
    if (trafficScore < 0.7) return 'medium';
    return 'high';
  }

  async predictTravelTime(routeData) {
    const trafficLevel = await this.predictTrafficLevel(routeData);
    const baseTime = routeData.distance * 1.2; // Tiempo base en minutos
    
    const trafficMultiplier = {
      'low': 1,
      'medium': 1.3,
      'high': 1.8
    };

    return Math.round(baseTime * trafficMultiplier[trafficLevel]);
  }
}

module.exports = new TrafficPredictionService();
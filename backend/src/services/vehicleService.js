// services/vehicleService.js
const Vehicle = require('../models/Vehicle');

class VehicleService {
  async getVehicleConsumption(vehicleId, distance, trafficLevel) {
    try {
      const vehicle = await Vehicle.findById(vehicleId);
      if (!vehicle) throw new Error('Vehículo no encontrado');

      const baseConsumption = this.getBaseConsumption(vehicle.engineType);
      const trafficFactor = this.getTrafficFactor(trafficLevel);
      
      return (distance / 100) * baseConsumption * trafficFactor;
    } catch (error) {
      throw new Error('Error al calcular consumo del vehículo');
    }
  }

  getBaseConsumption(engineType) {
    const consumptionRates = {
      'Bencina': 8.5,
      'Petróleo': 6.5
    };
    return consumptionRates[engineType] || 8.5;
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

module.exports = new VehicleService();
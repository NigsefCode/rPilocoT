// services/fuelPriceService.js
const FuelPrice = require('../models/FuelPrice');

class FuelPriceService {
  async getCurrentPrices() {
    try {
      const prices = await FuelPrice.find()
        .sort({ createdAt: -1 })
        .limit(2);
      
      return prices.reduce((acc, price) => {
        acc[price.fuelType] = price.price;
        return acc;
      }, {});
    } catch (error) {
      throw new Error('Error al obtener precios de combustible');
    }
  }

  async updatePrice(fuelType, newPrice, userId) {
    try {
      const price = new FuelPrice({
        fuelType,
        price: newPrice,
        updatedBy: userId
      });
      
      await price.save();
      return price;
    } catch (error) {
      throw new Error('Error al actualizar precio de combustible');
    }
  }

  async getPriceHistory(fuelType, days = 30) {
    try {
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - days);

      return await FuelPrice.find({
        fuelType,
        createdAt: { $gte: startDate }
      }).sort({ createdAt: 1 });
    } catch (error) {
      throw new Error('Error al obtener historial de precios');
    }
  }
}

module.exports = new FuelPriceService();
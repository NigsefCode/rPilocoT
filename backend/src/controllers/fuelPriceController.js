// controllers/fuelPriceController.js
const FuelPrice = require('../models/FuelPrice');

const fuelPriceController = {
  updateFuelPrice: async (req, res) => {
    try {
      // Verificar si el usuario es administrador
      if (req.user.role !== 'admin') {
        return res.status(403).json({
          message: 'No tiene permisos para actualizar precios de combustible'
        });
      }

      const { fuelType, price } = req.body;

      // Validar datos
      if (!fuelType || !price) {
        return res.status(400).json({
          message: 'Faltan datos necesarios'
        });
      }

      // Actualizar o crear nuevo precio
      const updatedPrice = await FuelPrice.findOneAndUpdate(
        { fuelType },
        {
          price,
          updatedBy: req.user.id
        },
        { new: true, upsert: true }
      );

      res.json(updatedPrice);
    } catch (error) {
      res.status(500).json({
        message: 'Error al actualizar precio de combustible',
        error: error.message
      });
    }
  },

  getCurrentPrices: async (req, res) => {
    try {
      const prices = await FuelPrice.find().sort({ updatedAt: -1 });
      
      // Convertir a objeto para fácil acceso
      const pricesObject = prices.reduce((acc, curr) => {
        acc[curr.fuelType] = curr.price;
        return acc;
      }, {});

      res.json(pricesObject);
    } catch (error) {
      res.status(500).json({
        message: 'Error al obtener precios de combustible',
        error: error.message
      });
    }
  }
};

module.exports = fuelPriceController;
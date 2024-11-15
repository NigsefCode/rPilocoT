// services/initializationService.js
const FuelPrice = require('../models/FuelPrice');
const User = require('../models/User');

const initializeFuelPrices = async () => {
  try {
    // Verificar si ya existen precios
    const existingPrices = await FuelPrice.find();
    
    if (existingPrices.length === 0) {
      // Buscar un usuario admin para la inicialización
      let adminUser = await User.findOne({ role: 'admin' });
      
      if (!adminUser) {
        // Si no hay admin, crear los precios sin updatedBy
        await FuelPrice.insertMany([
          {
            fuelType: 'Bencina',
            price: 1200
          },
          {
            fuelType: 'Petróleo',
            price: 1000
          }
        ]);
      } else {
        // Si hay admin, crear los precios con su ID
        await FuelPrice.insertMany([
          {
            fuelType: 'Bencina',
            price: 1200,
            updatedBy: adminUser._id
          },
          {
            fuelType: 'Petróleo',
            price: 1000,
            updatedBy: adminUser._id
          }
        ]);
      }
      console.log('Precios de combustible inicializados correctamente');
    } else {
      console.log('Los precios de combustible ya están inicializados');
    }
  } catch (error) {
    console.error('Error al inicializar precios de combustible:', error);
    // No lanzar el error para permitir que la aplicación continúe
    console.warn('Continuando sin inicialización de precios');
  }
};

module.exports = { initializeFuelPrices };
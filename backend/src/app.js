// app.js actualizado
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const connectDB = require('./config/database');
const corsOptions = require('./config/corsOptions');
const authRoutes = require('./routes/authRoutes');
const vehicleRoutes = require('./routes/vehicleRoutes');
const routeRoutes = require('./routes/routeRoutes');
const configRoutes = require('./routes/configRoutes');
const fuelPriceRoutes = require('./routes/fuelPriceRoutes');
const { initializeFuelPrices } = require('./services/initializationService');

const app = express();

// Inicialización de la aplicación
const initializeApp = async () => {
  try {
    await connectDB();
    console.log('Conectado a MongoDB');
    
    await initializeFuelPrices();
    console.log('Precios de combustible inicializados');
  } catch (error) {
    console.error('Error durante la inicialización:', error);
    process.exit(1);
  }
};

// Middleware
app.use(cors(corsOptions));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Logging middleware
app.use((req, res, next) => {
  console.log(`${req.method} ${req.path} - ${new Date().toISOString()}`);
  next();
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/vehicles', vehicleRoutes);
app.use('/api/routes', routeRoutes);
app.use('/api/config', configRoutes);
app.use('/api/fuel-prices', fuelPriceRoutes);

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({
    message: err.message || 'Error interno del servidor',
    stack: process.env.NODE_ENV === 'development' ? err.stack : undefined
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ message: 'Ruta no encontrada' });
});

const PORT = process.env.PORT || 5000;

initializeApp().then(() => {
  app.listen(PORT, () => {
    console.log(`Servidor corriendo en el puerto ${PORT}`);
    console.log(`Ambiente: ${process.env.NODE_ENV}`);
  });
}).catch(err => {
  console.error('Error al iniciar la aplicación:', err);
  process.exit(1);
});

module.exports = app;
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const connectDB = require('./config/database');
const corsOptions = require('./config/corsOptions');
const authRoutes = require('./routes/authRoutes');
const vehicleRoutes = require('./routes/vehicleRoutes')
const routeRoutes = require('./routes/routeRoutes')
const configRoutes = require('./routes/configRoutes')
const { initializeFuelPrices } = require('./services/initializationService');

const app = express();

// Conectar a la base de datos MongoDB y inicializar precios
const initializeApp = async () => {
  try {
    await connectDB();
    console.log('Conectado a MongoDB');
    
    // Inicializar precios de combustible
    await initializeFuelPrices();
    console.log('Precios de combustible inicializados');
  } catch (error) {
    console.error('Error durante la inicialización:', error);
    process.exit(1);
  }
};

// Middleware
app.use(cors({origin: '*'}));
app.use(express.json());

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/vehicles', vehicleRoutes);
app.use('/api/routes', routeRoutes);
app.use('/api/config', configRoutes);

// Error de manejo del middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send('Something broke!');
});

const PORT = process.env.PORT || 5000;

// Iniciar servidor
initializeApp().then(() => {
  app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
}).catch(err => {
  console.error('Error al iniciar la aplicación:', err);
  process.exit(1);
});
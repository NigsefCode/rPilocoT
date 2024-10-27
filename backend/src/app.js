require('dotenv').config();
const express = require('express');
const cors = require('cors');
const connectDB = require('./config/database');
const corsOptions = require('./config/corsOptions');
const authRoutes = require('./routes/authRoutes');
const vehicleRoutes = require('./routes/vehicleRoutes')

const app = express();

// Conectar a la base de datos MongoDB
connectDB();

// Middleware
app.use(cors({origin: '*'}));
app.use(express.json());

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/vehicles', vehicleRoutes);

// Error de manejo del middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send('Something broke!');
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
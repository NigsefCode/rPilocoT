const corsOptions = {
  origin: ['http://localhost:3000', 'http://localhost:5173'], // Agrega el dominio de Vue.js (Vite)
  optionsSuccessStatus: 200,
};

module.exports = corsOptions;

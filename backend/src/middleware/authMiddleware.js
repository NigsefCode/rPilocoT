// middleware/authMiddleware.js
const { verifyToken } = require('../utils/tokenManager');
const User = require('../models/User');

// Protección de rutas
const protect = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');

    if (!token) {
      return res.status(401).json({ message: 'No token, authorization denied' });
    }

    const decoded = verifyToken(token);

    // Si el token pertenece al administrador hardcodeado
    if (decoded.id === 'admin') {
      req.user = {
        id: 'admin',
        name: 'Admin',
        email: process.env.ADMIN_USERNAME,
        role: 'admin',
      };
      return next();
    }

    // Buscar usuario en la base de datos
    const user = await User.findById(decoded.id);
    if (!user) {
      return res.status(401).json({ message: 'Usuario no encontrado' });
    }

    req.user = user; // Esto incluirá el rol del usuario
    next();
  } catch (error) {
    res.status(401).json({ message: 'Token is not valid' });
  }
};

// Middleware para verificar rol de administrador
const isAdmin = (req, res, next) => {
  if (req.user && req.user.role === 'admin') {
    next();
  } else {
    res.status(403).json({ message: 'Acceso denegado - Se requiere rol de administrador' });
  }
};

module.exports = { protect, isAdmin };
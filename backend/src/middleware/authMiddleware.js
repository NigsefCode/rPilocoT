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
    
    // Obtener el usuario completo de la base de datos para tener acceso al rol
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
const User = require('../models/User');
const bcrypt = require('bcrypt');
const { generateToken } = require('../utils/tokenManager');
const userService = require('../services/userService');

// Registro de usuario
exports.register = async (req, res) => {
  try {
    const { name, email, password } = req.body;
    
    const userExists = await User.findOne({ email });
    if (userExists) {
      return res.status(400).json({ message: 'El usuario ya existe' });
    }
    // Encriptar contraseña
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const user = new User({
      name,
      email,
      password: hashedPassword
    });

    await user.save();
    const token = generateToken(user._id);

    res.status(201).json({
      message: 'Usuario registrado exitosamente',
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        hasCompletedQuestionnaire: user.hasCompletedQuestionnaire
      },
      token
    });
  } catch (error) {
    console.error('Error en registro:', error);
    res.status(500).json({ message: 'Error en el servidor', error: error.message });
  }
};

// Registro de usuario con Google
exports.registerGoogle = async (req, res) => {
  try {
    const { name, email } = req.body;

    console.log('Datos recibidos para registrar usuario de Google:', { name, email });

    // Registrar o actualizar el usuario utilizando el servicio
    const user = await userService.registerGoogleUser(name, email);
    console.log('Usuario encontrado/registrado:', user);

    // Generar un token JWT
    const token = generateToken(user._id);

    // Enviar la respuesta con el token y el usuario
    res.status(201).json({
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
        hasCompletedQuestionnaire: user.hasCompletedQuestionnaire,
      },
      token,
    });
  } catch (error) {
    console.error('Error registrando usuario de Google:', error);
    res.status(500).json({ message: 'Error al registrar usuario de Google', error: error.message });
  }
};


// Login de usuario
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({ message: 'Credenciales inválidas' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Credenciales inválidas' });
    }

    const token = generateToken(user._id);

    res.json({
      message: 'Login successful',
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        hasCompletedQuestionnaire: user.hasCompletedQuestionnaire
      },
      token
    });
  } catch (error) {
    console.error('Error en login:', error);
    res.status(500).json({ message: 'Error en el servidor', error: error.message });
  }
};

// Logout de usuario
exports.logout = async (req, res) => {
  try {
    res.json({ message: 'Logout successful' });
  } catch (error) {
    res.status(500).json({ message: 'Error en el servidor', error: error.message });
  }
};

// Obtener perfil de usuario
exports.getProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-password');
    if (!user) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }
    res.json(user);
  } catch (error) {
    console.error('Error al obtener perfil:', error);
    res.status(500).json({ message: 'Error en el servidor', error: error.message });
  }
};

// Actualizar contraseña
exports.updatePassword = async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;

    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }

    const isMatch = await bcrypt.compare(currentPassword, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Contraseña actual incorrecta' });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    user.password = hashedPassword;
    await user.save();

    res.json({ message: 'Contraseña actualizada exitosamente' });
  } catch (error) {
    console.error('Error actualizando contraseña:', error);
    res.status(500).json({ message: 'Error al actualizar la contraseña' });
  }
};

// Actualizar estado del cuestionario
exports.updateQuestionnaireStatus = async (req, res) => {
  try {
    const user = await User.findByIdAndUpdate(
      req.user.id,
      { hasCompletedQuestionnaire: true },
      { new: true }
    );

    if (!user) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }

    res.json({
      message: 'Estado del cuestionario actualizado',
      hasCompletedQuestionnaire: user.hasCompletedQuestionnaire
    });
  } catch (error) {
    console.error('Error actualizando estado del cuestionario:', error);
    res.status(500).json({ message: 'Error al actualizar estado del cuestionario' });
  }
};

exports.updateName = async (req, res) => {
  try {
    const { name } = req.body;
    console.log('Actualizando nombre para usuario ID:', req.user.id);
    console.log('Nuevo nombre:', name);

    const user = await User.findByIdAndUpdate(
      req.user.id,
      { name },
      { new: true }
    ).select('-password');

    if (!user) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }

    console.log('Nombre actualizado exitosamente');
    res.json({
      message: 'Nombre actualizado exitosamente',
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        hasCompletedQuestionnaire: user.hasCompletedQuestionnaire
      }
    });
  } catch (error) {
    console.error('Error actualizando nombre:', error);
    res.status(500).json({ 
      message: 'Error al actualizar el nombre',
      error: error.message 
    });
  }
};
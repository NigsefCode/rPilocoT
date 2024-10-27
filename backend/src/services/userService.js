const User = require('../models/User');

const userService = {
  // Crear un nuevo usuario
  createUser: async (userData) => {
    try {
      const newUser = new User(userData);
      await newUser.save();
      return newUser;
    } catch (error) {
      console.error('Error al crear usuario:', error);
      throw error;
    }
  },

  // Buscar un usuario por email
  findUserByEmail: async (email) => {
    try {
      return await User.findOne({ email });
    } catch (error) {
      console.error('Error al buscar usuario:', error);
      throw error;
    }
  },

  // Actualizar un usuario
  updateUser: async (userId, updateData) => {
    try {
      const updatedUser = await User.findByIdAndUpdate(userId, updateData, { new: true });
      return updatedUser;
    } catch (error) {
      console.error('Error al actualizar usuario:', error);
      throw error;
    }
  },

  // Eliminar un usuario
  deleteUser: async (userId) => {
    try {
      await User.findByIdAndDelete(userId);
    } catch (error) {
      console.error('Error al eliminar usuario:', error);
      throw error;
    }
  },

  // Listar todos los usuarios
  listUsers: async () => {
    try {
      return await User.find({});
    } catch (error) {
      console.error('Error al listar usuarios:', error);
      throw error;
    }
  }
};

module.exports = userService;
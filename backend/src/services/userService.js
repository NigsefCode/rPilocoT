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

  // Registrar o buscar un usuario de Google
  registerGoogleUser: async (name, email) => {
    try {
      // Validar que los datos de nombre y email están presentes
      if (!name || !email) {
        console.error('Error: Faltan datos necesarios para registrar usuario de Google (name o email).');
        throw new Error('Datos incompletos: name y email son requeridos');
      }

      console.log('Intentando registrar o buscar usuario de Google:', { name, email });

      // Buscar si el usuario ya existe por email
      let user = await User.findOne({ email });
      if (!user) {
        console.log('Usuario no encontrado, creando nuevo usuario...');

        // Si no existe, creamos un nuevo usuario
        user = new User({
          name,
          email,
          password: 'google_oauth', // Valor ficticio, ya que no se utiliza en este caso.
          role: 'user', // Se puede cambiar según sea necesario
        });

        console.log('Guardando nuevo usuario...');
        await user.save();
        console.log('Usuario creado y guardado exitosamente:', user);
      } else {
        console.log('Usuario encontrado:', user);
      }

      return user;
    } catch (error) {
      console.error('Error registrando usuario de Google:', error);
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
// src/services/authService.js
import axios from 'axios';

const API_URL = 'http://localhost:5000/api/auth';

export async function loginUser(email, password) {
  try {
    const response = await axios.post(`${API_URL}/login`, { email, password });
    console.log("email que se envia desde el front", email)
    return response.data; // Retornar el token y el usuario
  } catch (error) {
    // Manejo de errores
    throw error.response ? error.response.data.message : 'Error al iniciar sesión';
  }
}

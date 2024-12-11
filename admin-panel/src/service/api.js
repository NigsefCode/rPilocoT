import axios from 'axios';

const apiClient = axios.create({
  baseURL: 'http://localhost:5000/api', // Cambia la URL por la de tu backend
  headers: {
    'Content-Type': 'application/json',
  },
});

// Interceptor para manejar errores o agregar tokens de autenticación
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('authToken'); // Si usas autenticación
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

export default apiClient;

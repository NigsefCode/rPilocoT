import axios from 'axios';

const API_URL = 'http://localhost:5000/api/fuel-prices';

export async function getFuelPrices() {
  try {
    const token = localStorage.getItem('token');
    const response = await axios.get(API_URL, {
      headers: { Authorization: `Bearer ${token}` },
    });
    return response.data;
  } catch (error) {
    console.error('Error al obtener precios de combustible:', error);
    throw error;
  }
}

export async function updateFuelPrice(fuelType, price) {
  try {
    const token = localStorage.getItem('token');
    const response = await axios.post(
      API_URL,
      { fuelType, price }, // Asegúrate de enviar los datos correctamente
      { headers: { Authorization: `Bearer ${token}` } }
    );
    return response.data;
  } catch (error) {
    console.error('Error al actualizar precio de combustible:', error);
    throw error.response
      ? error.response.data.message
      : 'Error desconocido al actualizar';
  }
}

<template>
  <div class="fuel-prices">
    <h1>Precios de Combustible</h1>
    <div v-if="loading">Cargando...</div>
    <ul v-else>
      <li v-for="(price, type) in prices" :key="type">
        {{ type }}: {{ price }} CLP
      </li>
    </ul>

    <h2>Actualizar Precio</h2>
    <form @submit.prevent="handleUpdate">
      <label for="fuelType">Tipo de Combustible:</label>
      <select v-model="fuelType" required>
        <option value="Bencina">Bencina</option>
        <option value="Petróleo">Petróleo</option>
      </select>

      <label for="price">Nuevo Precio:</label>
      <input type="number" v-model="price" required />

      <button type="submit">Actualizar</button>
    </form>
  </div>
</template>

<script>
import { getFuelPrices, updateFuelPrice } from '../service/fuelPriceService.js';

export default {
  name: 'FuelPrices',
  data() {
    return {
      prices: {},
      fuelType: '',
      price: 0,
      loading: true,
    };
  },
  async created() {
    try {
      this.prices = await getFuelPrices();
    } finally {
      this.loading = false;
    }
  },
  methods: {
    async handleUpdate() {
      try {
        const updatedPrice = await updateFuelPrice(this.fuelType, this.price);
        this.prices[this.fuelType] = updatedPrice.price;
        alert('Precio actualizado con éxito');
      } catch (error) {
        this.error = error;
        console.error('Error al actualizar precio de combustible:', error);
      }
    }
  }
};
</script>

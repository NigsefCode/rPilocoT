<template>
    <div>
      <h1>Administrar Precios de Combustible</h1>
      <div v-if="loading">Cargando...</div>
      <div v-else>
        <ul>
          <li v-for="(price, type) in fuelPrices" :key="type">
            {{ type }}: ${{ price }}
          </li>
        </ul>
        <form @submit.prevent="updatePrice">
          <label for="fuelType">Tipo de Combustible:</label>
          <select v-model="fuelType" required>
            <option value="Bencina">Bencina</option>
            <option value="Petróleo">Petróleo</option>
          </select>
          <label for="price">Precio:</label>
          <input type="number" v-model="price" required />
          <button type="submit">Actualizar Precio</button>
        </form>
        <p v-if="error" style="color: red;">{{ error }}</p>
        <p v-if="success" style="color: green;">{{ success }}</p>
      </div>
    </div>
  </template>
  
  <script>
  import { getFuelPrices, updateFuelPrice } from '../services/fuelPriceService';
  
  export default {
    name: 'FuelPriceManager',
    data() {
      return {
        fuelPrices: {},
        fuelType: '',
        price: '',
        loading: true,
        error: null,
        success: null,
      };
    },
    async created() {
      try {
        this.fuelPrices = await getFuelPrices();
      } catch (err) {
        this.error = 'Error al cargar precios.';
      } finally {
        this.loading = false;
      }
    },
    methods: {
      async updatePrice() {
        try {
          const updatedPrice = await updateFuelPrice(this.fuelType, this.price);
          this.fuelPrices[this.fuelType] = updatedPrice.price;
          this.success = 'Precio actualizado correctamente.';
          this.error = null;
        } catch (err) {
          this.error = 'Error al actualizar precio.';
          this.success = null;
        }
      },
    },
  };
  </script>
  
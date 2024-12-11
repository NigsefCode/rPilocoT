<template>
  <v-app-bar app>
    <!-- Botón de menú para controlar el drawer -->
    <v-app-bar-nav-icon @click="$emit('toggle-drawer')" />
    <v-app-bar-title>Admin Panel</v-app-bar-title>
    <v-spacer></v-spacer>
    <v-btn @click="logout">Cerrar Sesión</v-btn>
  </v-app-bar>
</template>

<script lang="ts">
import { defineComponent } from 'vue';

export default defineComponent({
  name: 'NavBar',
  emits: ['toggle-drawer'], // Emite un evento para que el App.vue controle el drawer
  methods: {
    logout() {
      localStorage.removeItem('userRole');
      this.$router.push('/');
    }
  }
});
</script>

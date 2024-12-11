<template>
    <div class="dashboard">
      <h1>Bienvenido al Dashboard</h1>
      <p>Has iniciado sesión como: {{ user?.username }}</p>
      <button @click="logout">Cerrar Sesión</button>
    </div>
  </template>
  
  <script>
  export default {
    name: 'Dashboard',
    data() {
      return {
        user: null, // Almacena la información del usuario
      };
    },
    created() {
      // Verifica si el usuario está en localStorage
      const user = localStorage.getItem('user');
      if (user) {
        this.user = JSON.parse(user);
      } else {
        this.$router.push('/'); // Redirige al login si no hay usuario
      }
    },
    methods: {
      logout() {
        localStorage.removeItem('user'); // Elimina al usuario de localStorage
        this.$router.push('/'); // Redirige al login
      },
    },
  };
  </script>
  
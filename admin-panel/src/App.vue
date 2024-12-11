<template>
  <div id="app">
    <nav>
      <router-link to="/dashboard">Dashboard</router-link>
      <router-link to="/fuel-prices">Precios de Combustible</router-link>
    </nav>
    <router-view />
  </div>
</template>

<script>
export default {
  name: 'App',
};
</script>

<style>
/* Estilos globales opcionales */
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  text-align: center;
  color: #2c3e50;
  margin-top: 0;
}
</style>

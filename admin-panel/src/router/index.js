import { createRouter, createWebHistory } from 'vue-router';
import Login from '../views/Login.vue';
import Dashboard from '../views/Dashboard.vue';
import FuelPrices from '../views/FuelPrices.vue';

// Definición de rutas
const routes = [
  { path: '/', name: 'Login', component: Login },
  { path: '/dashboard', name: 'Dashboard', component: Dashboard },
  { path: '/fuel-prices', name: 'FuelPrices', component: FuelPrices },
];

// Creación del router
const router = createRouter({
  history: createWebHistory(),
  routes,
});

// Protección de rutas con navegación global
router.beforeEach((to, from, next) => {
  const isAuthenticated = localStorage.getItem('user');
  
  // Permitir acceso a Login sin autenticación
  if (to.name === 'Login') {
    next();
  }
  // Redirigir a Login si no está autenticado
  else if (!isAuthenticated) {
    next({ name: 'Login' });
  }
  // Permitir acceso si está autenticado
  else {
    next();
  }
});

export default router;

import { createRouter, createWebHistory } from 'vue-router';
import HomeView from '../views/HomeView.vue';
import AdminDashboard from '../views/AdminDashboard.vue';

const routes = [
  {
    path: '/',
    name: 'Home',
    component: HomeView
  },
  {
    path: '/admin',
    name: 'Admin',
    component: AdminDashboard,
    meta: { requiresAuth: true }
  }
];

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes
});

router.beforeEach((to, from, next) => {
  const isAdmin = localStorage.getItem('userRole') === 'admin';
  if (to.meta.requiresAuth && !isAdmin) {
    next({ name: 'Home' });
  } else {
    next();
  }
});

export default router;

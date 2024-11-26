<template>
  <v-app>
    <!-- Barra de Navegación -->
    <NavBar @toggle-drawer="toggleDrawer" />

    <!-- Barra Lateral -->
    <v-navigation-drawer app v-model="drawer" permanent>
      <v-list>
        <v-list-item-group>
          <v-list-item
            v-for="item in items"
            :key="item.title"
            :to="item.route"
            prepend-icon="item.icon"
          >
            <v-list-item-content>
              <v-list-item-title>{{ item.title }}</v-list-item-title>
            </v-list-item-content>
          </v-list-item>
        </v-list-item-group>
      </v-list>
    </v-navigation-drawer>

    <!-- Contenido Principal -->
    <v-main>
      <v-container>
        <router-view />
      </v-container>
    </v-main>

    <!-- Pie de Página -->
    <FooterComponent />
  </v-app>
</template>

<script lang="ts">
import { defineComponent, ref } from 'vue';
import NavBar from './components/NavBar.vue';
import FooterComponent from './components/Footer.vue';

export default defineComponent({
  name: 'App',
  components: {
    NavBar,
    FooterComponent
  },
  setup() {
    const drawer = ref(true);

    const items = [
      { title: 'Inicio', route: '/', icon: 'mdi-home' },
      { title: 'Panel de Administración', route: '/admin', icon: 'mdi-view-dashboard' },
    ];

    // Función para alternar la visibilidad del drawer
    const toggleDrawer = () => {
      drawer.value = !drawer.value;
    };

    return {
      drawer,
      items,
      toggleDrawer
    };
  }
});
</script>

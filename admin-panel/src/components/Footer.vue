<template>
  <v-footer app>
    <v-container>
      <v-row>
        <v-col class="text-center">
          <span>© {{ new Date().getFullYear() }} Admin Panel. Todos los derechos reservados.</span>
        </v-col>
      </v-row>
    </v-container>
  </v-footer>
</template>

<script lang="ts">
import { defineComponent } from 'vue';

export default defineComponent({
  name: 'FooterComponent', // Nombre del componente

  setup() {
    return {
      new: Date // Esto permite obtener el año actual automáticamente en el footer
    };
  }
});
</script>

<style scoped>
/* Puedes añadir estilos personalizados si lo deseas */
v-footer {
  background-color: #424242;
  /* Cambia el color del fondo del footer */
  color: #ffffff;
  /* Cambia el color del texto */
}
</style>
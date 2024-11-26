<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-card>
          <v-card-title>Bienvenido a la Página Principal</v-card-title>
          <v-card-text>
            Esta es la página principal de la aplicación.
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>
  
<script lang="ts">
import { defineComponent } from 'vue';
  
export default defineComponent({
  name: 'HomeView',
});
</script>
<template>
  <v-container>
    <v-row>
      <v-col cols="12" md="6">
        <v-card>
          <v-card-title>Estadísticas Generales</v-card-title>
          <v-card-text>
            Aquí puedes agregar datos relevantes, como el número de usuarios registrados, el número de vehículos, etc.
          </v-card-text>
        </v-card>
      </v-col>
      <v-col cols="12" md="6">
        <v-card>
          <v-card-title>Actividad Reciente</v-card-title>
          <v-card-text>
            Muestra la actividad reciente de los usuarios, por ejemplo, rutas calculadas o vehículos añadidos.
          </v-card-text>
        </v-card>
      </v-col>
      <v-col cols="12">
        <v-card>
          <v-card-title>Resumen de Consumo de Combustible</v-card-title>
          <v-card-text>
            Aquí puedes integrar gráficos para mostrar información sobre el consumo de combustible, rutas más utilizadas, etc.
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script lang="ts">
import { defineComponent } from 'vue';

export default defineComponent({
  name: 'AdminDashboard',
});
</script>

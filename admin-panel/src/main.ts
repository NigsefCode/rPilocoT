import { createApp } from 'vue';
import App from './App.vue';
import vuetify from './plugins/vuetify';  // Importa el tema de Vuetify
import router from './router';

const app = createApp(App);

app.use(vuetify);
app.use(router);

app.mount('#app');

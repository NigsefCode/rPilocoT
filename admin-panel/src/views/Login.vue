<template>
  <div class="login">
    <h1>Iniciar Sesión</h1>
    <form @submit.prevent="handleLogin">
      <div>
        <label for="username">Usuario:</label>
        <input type="text" id="username" v-model="username" required />
      </div>
      <div>
        <label for="password">Contraseña:</label>
        <input type="password" id="password" v-model="password" required />
      </div>
      <button type="submit">Iniciar Sesión</button>
      <p v-if="error" style="color: red;">{{ error }}</p>
    </form>
  </div>
</template>

<script>
import { loginUser } from '../service/authService.js';

export default {
  name: 'Login',
  data() {
    return {
      username: '',
      password: '',
      error: '',
    };
  },
  methods: {
    async handleLogin() {
      try {
        const data = await loginUser(this.username, this.password);

        // Almacenar token y redirigir
        localStorage.setItem('token', data.token);
        localStorage.setItem('user', JSON.stringify({ email: this.username }));
        this.$router.push('/dashboard');
      } catch (error) {
        this.error = error;
      }
    },
  },
};
</script>

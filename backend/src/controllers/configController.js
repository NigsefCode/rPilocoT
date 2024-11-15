const configController = {
  getGoogleMapsConfig: async (req, res) => {
    try {
      // La API key está en las variables de entorno
      const apiKey = process.env.GOOGLE_MAPS_API_KEY;
      
      if (!apiKey) {
        return res.status(500).json({
          message: 'API key no configurada en el servidor'
        });
      }

      res.json({ apiKey });
    } catch (error) {
      res.status(500).json({
        message: 'Error al obtener configuración',
        error: error.message
      });
    }
  }
};

module.exports = configController;
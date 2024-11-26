// models/Route.js
const mongoose = require('mongoose');

const coordinateSchema = new mongoose.Schema({
  lat: { type: Number, required: true },
  lng: { type: Number, required: true },
  name: { type: String, required: true }
}, { _id: false });

const routeSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  vehicleId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Vehicle',
    required: true
  },
  origin: {
    type: coordinateSchema,
    required: true
  },
  destination: {
    type: coordinateSchema,
    required: true
  },
  distance: {
    type: Number,
    required: true
  },
  duration: {
    type: Number,
    required: true
  },
  fuelConsumption: {
    type: Number,
    required: true
  },
  routeType: {
    type: String,
    enum: ['optimal', 'fastest'],
    required: true
  },
  waypoints: [{
    type: coordinateSchema
  }],
  polyline: {
    type: String,
    required: true
  },
  trafficLevel: {
    type: String,
    enum: ['low', 'medium', 'high'],
    default: 'medium'
  },
  estimatedCost: {
    type: Number,
    required: true
  },
  weather: {
    condition: String,
    temperature: Number,
    updatedAt: Date
  },
  status: {
    type: String,
    enum: ['active', 'completed', 'cancelled'],
    default: 'active'
  }
}, {
  timestamps: true
});

routeSchema.pre('save', async function(next) {
  try {
    // Si el estimatedCost ya está establecido y fuelConsumption no ha cambiado,
    // no necesitamos recalcularlo
    if (this.estimatedCost && !this.isModified('fuelConsumption')) {
      return next();
    }

    const FuelPrice = mongoose.model('FuelPrice');
    const Vehicle = mongoose.model('Vehicle');
    
    const vehicle = await Vehicle.findById(this.vehicleId);
    if (!vehicle) {
      throw new Error('Vehículo no encontrado');
    }

    const fuelPrice = await FuelPrice.findOne({ 
      fuelType: vehicle.engineType 
    }).sort({ createdAt: -1 });
    
    if (!fuelPrice) {
      throw new Error('Precio de combustible no encontrado');
    }

    this.estimatedCost = this.fuelConsumption * fuelPrice.price;
    next();
  } catch (error) {
    next(error);
  }
});

module.exports = mongoose.model('Route', routeSchema);
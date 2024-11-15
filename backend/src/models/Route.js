// models/Route.js
const mongoose = require('mongoose');

const coordinateSchema = new mongoose.Schema({
  lat: { type: Number, required: true },
  lng: { type: Number, required: true }
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
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('Route', routeSchema);
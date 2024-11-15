// models/FuelPrice.js
const mongoose = require('mongoose');

const fuelPriceSchema = new mongoose.Schema({
  fuelType: {
    type: String,
    enum: ['Bencina', 'Petróleo'],
    required: true
  },
  price: {
    type: Number,
    required: true
  },
  updatedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: false
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('FuelPrice', fuelPriceSchema);
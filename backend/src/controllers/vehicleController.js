const Vehicle = require('../models/Vehicle');

// Obtener todos los vehículos del usuario
exports.getUserVehicles = async (req, res) => {
  try {
    const vehicles = await Vehicle.find({ userId: req.user.id });
    res.json(vehicles);
  } catch (error) {
    console.error('Error getting vehicles:', error);
    res.status(500).json({ message: 'Error getting vehicles', error: error.message });
  }
};

// Obtener el vehículo por defecto del usuario
exports.getDefaultVehicle = async (req, res) => {
  try {
    const vehicle = await Vehicle.findOne({ userId: req.user.id }).sort({ createdAt: -1 });
    
    if (!vehicle) {
      return res.status(404).json({ message: 'No vehicles found for this user' });
    }
    
    res.json(vehicle);
  } catch (error) {
    console.error('Error getting default vehicle:', error);
    res.status(500).json({ message: 'Error getting default vehicle', error: error.message });
  }
};

// Obtener un vehículo específico
exports.getVehicle = async (req, res) => {
  try {
    const vehicle = await Vehicle.findOne({
      _id: req.params.id,
      userId: req.user.id
    });
    
    if (!vehicle) {
      return res.status(404).json({ message: 'Vehicle not found' });
    }
    
    res.json(vehicle);
  } catch (error) {
    console.error('Error getting vehicle:', error);
    res.status(500).json({ message: 'Error getting vehicle', error: error.message });
  }
};

// Crear un nuevo vehículo
exports.createVehicle = async (req, res) => {
  try {
    const vehicle = new Vehicle({
      ...req.body,
      userId: req.user.id
    });

    await vehicle.save();
    res.status(201).json(vehicle);
  } catch (error) {
    console.error('Error creating vehicle:', error);
    res.status(500).json({ message: 'Error creating vehicle', error: error.message });
  }
};

// Actualizar un vehículo
exports.updateVehicle = async (req, res) => {
  try {
    const vehicle = await Vehicle.findOneAndUpdate(
      { _id: req.params.id, userId: req.user.id },
      req.body,
      { new: true, runValidators: true }
    );

    if (!vehicle) {
      return res.status(404).json({ message: 'Vehicle not found' });
    }

    res.json(vehicle);
  } catch (error) {
    console.error('Error updating vehicle:', error);
    res.status(500).json({ message: 'Error updating vehicle', error: error.message });
  }
};

// Eliminar un vehículo
exports.deleteVehicle = async (req, res) => {
  try {
    const vehicle = await Vehicle.findOneAndDelete({
      _id: req.params.id,
      userId: req.user.id
    });

    if (!vehicle) {
      return res.status(404).json({ message: 'Vehicle not found' });
    }

    res.json({ message: 'Vehicle deleted successfully' });
  } catch (error) {
    console.error('Error deleting vehicle:', error);
    res.status(500).json({ message: 'Error deleting vehicle', error: error.message });
  }
};
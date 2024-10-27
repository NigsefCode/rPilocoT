import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/vehicle_service.dart';

class EditVehicleScreen extends StatefulWidget {
  final Vehicle vehicle;

  const EditVehicleScreen({super.key, required this.vehicle});

  @override
  _EditVehicleScreenState createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final VehicleService _vehicleService = VehicleService();
  bool _isLoading = false;

  late String _brand;
  late String _model;
  late String _year;
  late String _engineType;
  late String _engineSize;

  final List<String> _engineTypes = ['Bencina', 'Petróleo'];

  @override
  void initState() {
    super.initState();
    _brand = widget.vehicle.brand;
    _model = widget.vehicle.model;
    _year = widget.vehicle.year;
    _engineType = widget.vehicle.engineType;
    _engineSize = widget.vehicle.engineSize;
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      _formKey.currentState!.save();

      try {
        final updatedVehicle = Vehicle(
          id: widget.vehicle.id,
          brand: _brand,
          model: _model,
          year: _year,
          engineType: _engineType,
          engineSize: _engineSize,
          userId: widget.vehicle.userId,
        );

        await _vehicleService.updateVehicle(updatedVehicle);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehículo actualizado exitosamente')),
          );
          Navigator.pop(
              context, true); // true indica que se actualizó exitosamente
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar el vehículo: $e')),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Vehículo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                initialValue: _brand,
                decoration: const InputDecoration(
                  labelText: 'Marca',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_car),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Ingrese la marca' : null,
                onSaved: (value) => _brand = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _model,
                decoration: const InputDecoration(
                  labelText: 'Modelo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.car_repair),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Ingrese el modelo' : null,
                onSaved: (value) => _model = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _year,
                decoration: const InputDecoration(
                  labelText: 'Año',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Ingrese el año' : null,
                onSaved: (value) => _year = value!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _engineType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Combustible',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_gas_station),
                ),
                items: _engineTypes.map((String type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() => _engineType = value!);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _engineSize,
                decoration: const InputDecoration(
                  labelText: 'Cilindrada (cc)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.speed),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Ingrese la cilindrada' : null,
                onSaved: (value) => _engineSize = value!,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Guardar Cambios',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

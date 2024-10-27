import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/vehicle_service.dart';
import '../services/auth_service.dart';

class VehicleQuestionnaireScreen extends StatefulWidget {
  final bool isFirstTime;

  const VehicleQuestionnaireScreen({
    super.key,
    this.isFirstTime = false,
  });

  @override
  _VehicleQuestionnaireScreenState createState() =>
      _VehicleQuestionnaireScreenState();
}

class _VehicleQuestionnaireScreenState
    extends State<VehicleQuestionnaireScreen> {
  final _formKey = GlobalKey<FormState>();
  final VehicleService _vehicleService = VehicleService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  String _brand = '';
  String _model = '';
  String _year = '';
  String _engineType = 'Bencina';
  String _engineSize = '';

  final List<String> _engineTypes = ['Bencina', 'Petróleo'];

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final currentUser = await _authService.getCurrentUser();
        if (currentUser == null) {
          throw Exception('No user found');
        }

        _formKey.currentState!.save();

        final vehicle = Vehicle(
          brand: _brand,
          model: _model,
          year: _year,
          engineType: _engineType,
          engineSize: _engineSize,
          userId: currentUser.id!,
        );

        await _vehicleService.addVehicle(vehicle);

        // Solo actualizamos el estado del cuestionario si es la primera vez
        if (widget.isFirstTime) {
          await _authService.updateQuestionnaireStatus();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehículo registrado exitosamente')),
          );

          // Si es la primera vez, vamos al home, si no, volvemos atrás
          if (widget.isFirstTime) {
            Navigator.pushReplacementNamed(context, '/main');
          } else {
            Navigator.pop(context,
                true); // Retornamos true para indicar que se agregó un vehículo
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Vehículo'),
        leading: widget.isFirstTime
            ? null // No mostrar botón de retroceso si es primera vez
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Ingresa la información de tu vehículo',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Marca',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_car),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Ingresa la marca' : null,
                onSaved: (value) => _brand = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Modelo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.car_repair),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Ingresa el modelo' : null,
                onSaved: (value) => _model = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Año',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Ingresa el año' : null,
                onSaved: (value) => _year = value!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Tipo de Combustible',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_gas_station),
                ),
                value: _engineType,
                items: _engineTypes.map((String type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _engineType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Cilindrada (cc)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.speed),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Ingresa la cilindrada' : null,
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
                        'Guardar Vehículo',
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

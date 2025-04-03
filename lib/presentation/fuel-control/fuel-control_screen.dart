import 'package:billing/application/auth/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:billing/application/fuel-control/fuel-control_service.dart';
import 'package:billing/domain/fuel-control/FuelControl.dart';

class FuelControlScreen extends StatefulWidget {
  const FuelControlScreen({super.key});

  @override
  State<FuelControlScreen> createState() => _FuelControlScreenState();
}

class _FuelControlScreenState extends State<FuelControlScreen> {
  final _formKey = GlobalKey<FormState>();
  final FuelControlService _fuelControlService = FuelControlService();
  final LocalStorageService _localStorageService = LocalStorageService();
  
  // Form field controllers
  final TextEditingController _estacionServicioController = TextEditingController();
  final TextEditingController _nroFacturaController = TextEditingController();
  final TextEditingController _importeController = TextEditingController();
  final TextEditingController _kilometrajeController = TextEditingController();
  final TextEditingController _obsController = TextEditingController();
  
  List<CombustibleControl> _carsList = [];
  CombustibleControl? _selectedCar;
  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  @override
  void dispose() {
    _estacionServicioController.dispose();
    _nroFacturaController.dispose();
    _importeController.dispose();
    _kilometrajeController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  Future<void> _loadCars() async {
    setState(() => _isLoading = true);
    try {
      final cars = await _fuelControlService.getCars();
      setState(() {
        _carsList = cars;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error al cargar vehículos: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      final fuelControl = CombustibleControl(
        estacionServicio: _estacionServicioController.text,
        nroFactura: _nroFacturaController.text,
        importe: double.tryParse(_importeController.text) ?? 0.0,
        kilometraje: double.tryParse(_kilometrajeController.text) ?? 0.0,
        obs: _obsController.text,
        idCoche: _selectedCar?.idCoche,
        audUsuario: await _localStorageService.getCodUsuario()
      );
      
      await _fuelControlService.registerFuelControl(fuelControl);
      
      if (mounted) {
        _showSnackBar('Registro de combustible completado con éxito');
        _resetForm();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error al registrar: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
  
  void _resetForm() {
    _formKey.currentState!.reset();
    _estacionServicioController.clear();
    _nroFacturaController.clear();
    _importeController.clear();
    _kilometrajeController.clear();
    _obsController.clear();
    setState(() {
      _selectedCar = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Combustible'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.background,
                  Theme.of(context).colorScheme.surface,
                ],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información de Repostaje',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 24),

                        // Vehículo
                        DropdownButtonFormField<CombustibleControl>(
                          decoration: InputDecoration(
                            labelText: 'Vehículo',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.directions_car),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                          ),
                          value: _selectedCar,
                          hint: const Text('Seleccione un vehículo'),
                          items: _carsList.map((car) {
                            return DropdownMenuItem<CombustibleControl>(
                              value: car,
                              child: Text(car.coche ?? 'Sin nombre'),
                            );
                          }).toList(),
                          onChanged: (CombustibleControl? value) {
                            setState(() {
                              _selectedCar = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Por favor seleccione un vehículo';
                            }
                            return null;
                          },
                          isExpanded: true,
                        ),
                        const SizedBox(height: 16),

                        // Estación de servicio
                        TextFormField(
                          controller: _estacionServicioController,
                          decoration: InputDecoration(
                            labelText: 'Estación de Servicio',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.local_gas_station),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Campo requerido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Nro. Factura
                        TextFormField(
                          controller: _nroFacturaController,
                          decoration: InputDecoration(
                            labelText: 'Nro. Factura',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.receipt),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Campo requerido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Importe
                        TextFormField(
                          controller: _importeController,
                          decoration: InputDecoration(
                            labelText: 'Importe',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.attach_money),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Campo requerido';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Valor numérico inválido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Kilometraje
                        TextFormField(
                          controller: _kilometrajeController,
                          decoration: InputDecoration(
                            labelText: 'Kilometraje',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.speed),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Campo requerido';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Valor numérico inválido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Observaciones
                        TextFormField(
                          controller: _obsController,
                          decoration: InputDecoration(
                            labelText: 'Observaciones',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.comment),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 32),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _isSubmitting ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: _isSubmitting 
                              ? const SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  )
                                )
                              : const Icon(Icons.save),
                            label: Text(
                              _isSubmitting ? 'Registrando...' : 'Registrar Control de Combustible',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
    );
  }
}
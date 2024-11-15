import 'package:billing/application/auth/local_storage_service.dart';
import 'package:billing/application/driver-car/driver-car_service.dart';
import 'package:billing/domain/auth/login.dart';
import 'package:billing/domain/driver-car/SolicitudChofer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SolicitudChoferScreen extends StatefulWidget {
  const SolicitudChoferScreen({Key? key}) : super(key: key);

  @override
  State<SolicitudChoferScreen> createState() => _SolicitudChoferScreenState();
}

class _SolicitudChoferScreenState extends State<SolicitudChoferScreen> {
  final LocalStorageService _localStorageService = LocalStorageService();
  final DriverCarService _driverCarService = DriverCarService();
  
  Login? userData;
  List<SolicitudChofer> _solicitudes = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _initialLoad();
  }

  Future<void> _initialLoad() async {
    await _getUserData();
    await _loadSolicitudes();
  }
  
  Future<void> _getUserData() async {
    userData = await _localStorageService.getUser();
  }

  Future<void> _loadSolicitudes() async {
    try {
      setState(() => _isLoading = true);
      // Asumiendo que tienes un método en tu servicio para obtener las solicitudes
      //final solicitudes = await _driverCarService.getSolicitudesChofer();
      setState(() {
        //_solicitudes = solicitudes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error al cargar las solicitudes: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _getEstadoText(int estado) {
    switch (estado) {
      case 1:
        return 'Pendiente';
      case 2:
        return 'Aprobado';
      case 3:
        return 'Rechazado';
      default:
        return 'Desconocido';
    }
  }

  Color _getEstadoColor(int estado) {
    switch (estado) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Solicitudes de Chofer'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSolicitudes,
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormularioSolicitud(context),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_solicitudes.isEmpty) {
      return const Center(
        child: Text(
          'No hay solicitudes registradas',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSolicitudes,
      child: ListView.builder(
        itemCount: _solicitudes.length,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          final solicitud = _solicitudes[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Solicitud #${solicitud.idSolicitud}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Chip(
                    label: Text(
                      _getEstadoText(solicitud.estado ?? 1),
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: _getEstadoColor(solicitud.estado ?? 1),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Fecha: ${DateFormat('dd/MM/yyyy').format(solicitud.fechaSolicitud ?? DateTime.now())}',
                  ),
                  const SizedBox(height: 4),
                  Text('Motivo: ${solicitud.motivo}'),
                  const SizedBox(height: 4),
                  Text('Cargo: ${solicitud.cargo}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _mostrarFormularioSolicitud(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();
    final _motivoController = TextEditingController();
    final DateTime _fechaSolicitud = DateTime.now();
    int? _estado = 1;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Nueva Solicitud',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Fecha Solicitud como label
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fecha de Solicitud',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            child: Text(
                              DateFormat('dd/MM/yyyy').format(_fechaSolicitud),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _motivoController,
                        maxLength: 500,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Motivo',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese el motivo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Cargo como label
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cargo',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            child: Text(
                              userData?.cargo ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                // Crear objeto SolicitudChofer
                                SolicitudChofer nuevaSolicitud = SolicitudChofer(
                          
                                  motivo: _motivoController.text,
                                  codEmpSoli: userData?.codEmpleado ?? 0,
                                  cargo: userData?.cargo,
                                  estado: _estado,
                                  audUsuario: userData?.codUsuario?? 0,
                                );

                                // Guardar la solicitud
                                await _driverCarService.registerSolicitudChofer(nuevaSolicitud);
                                
                                // Cerrar el diálogo
                                Navigator.pop(context);
                                
                                // Mostrar mensaje de éxito
                                _showSuccessSnackBar('Solicitud creada con éxito');
                                
                                // Recargar la lista de solicitudes
                                await _loadSolicitudes();
                                
                              } catch (e) {
                                _showErrorSnackBar('Error al crear la solicitud: $e');
                              }
                            }
                          },
                          child: const Text(
                            'Guardar Solicitud',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
import 'package:billing/application/auth/local_storage_service.dart';
import 'package:billing/application/driver-car/driver-car_service.dart';
import 'package:billing/domain/auth/login.dart';
import 'package:billing/domain/driver-car/SolicitudChofer.dart';
import 'package:billing/domain/driver-car/TipoSolicitud.dart';
import 'package:billing/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SolicitudChoferScreen extends StatefulWidget {
  const SolicitudChoferScreen({super.key});

  @override
  State<SolicitudChoferScreen> createState() => _SolicitudChoferScreenState();
}

class _SolicitudChoferScreenState extends TokenAwareState<SolicitudChoferScreen > {// aqui modificaciones para token
  final LocalStorageService _localStorageService = LocalStorageService();
  final DriverCarService _driverCarService = DriverCarService();

  Login? userData;
  List<SolicitudChofer> _solicitudes = [];
  List<SolicitudChofer> _coches = [];
  List<TipoSolicitud> _tiposSolicitudes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialLoad();
  }

  Future<void> _initialLoad() async {
    setState(() => _isLoading = true);
    await _getUserData();
    await _loadSolicitudes();
    await _loadCoches();
    await _obtenerTipoSolicitudes();
    setState(() => _isLoading = false);
  }

  Future<void> _getUserData() async {
    userData = await _localStorageService.getUser();
  }

  Future<void> _loadSolicitudes() async {
    try {
      final solicitudes =
          await _driverCarService.obtainSolicitudes(userData?.codEmpleado ?? 0);
      setState(() => _solicitudes = solicitudes);
    } catch (e) {
      _showErrorSnackBar('Error al cargar las solicitudes: $e');
    }
  }

  Future<void> _loadCoches() async {
    try {
      final coches = await _driverCarService.obtainCoches();
      setState(() => _coches = coches);
    } catch (e) {
      _showErrorSnackBar('Error al cargar los coches: $e');
    }
  }

  Future<void> _obtenerTipoSolicitudes() async {
    try {
      final tipoSolicitudes = await _driverCarService.lstTipoSolicitudes();
      setState(() => _tiposSolicitudes = tipoSolicitudes);
    } catch (e) {
      _showErrorSnackBar('Error al cargar los tipos de solicitudes: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'Pendiente':
        return Colors.orange;
      case 'Aprobada':
        return Colors.green;
      case 'Rechazada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gestión de Vehículos'),
          backgroundColor: Colors.blue,
          bottom: const TabBar(
            tabs: [
              Tab(
                  icon: Icon(Icons.directions_car),
                  text: 'Estado de Vehículos'),
              Tab(icon: Icon(Icons.assignment), text: 'Mis Solicitudes'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _initialLoad,
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildVehiculosTab(),
            _buildSolicitudesTab(),
          ],
        ),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Builder(
      builder: (context) {
        final TabController tabController = DefaultTabController.of(context);
        return Visibility(
          visible: tabController.index == 0,
          child: FloatingActionButton(
            onPressed: () => _mostrarFormularioSolicitud(context),
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildSolicitudesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
          return _buildSolicitudCard(_solicitudes[index]);
        },
      ),
    );
  }

  Widget _buildVehiculosTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_coches.isEmpty) {
      return const Center(
        child: Text(
          'No hay vehículos registrados',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCoches,
      child: ListView.builder(
        itemCount: _coches.length,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          return _buildVehiculoCard(_coches[index]);
        },
      ),
    );
  }

  Widget _buildSolicitudCard(SolicitudChofer solicitud) {
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
                solicitud.estadoCad ?? '',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: _getEstadoColor(solicitud.estadoCad ?? ''),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Fecha: ${solicitud.fechaSolicitudCad != null ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.tryParse(solicitud.fechaSolicitudCad!) ?? DateTime.now()) : 'No disponible'}',
            ),
            const SizedBox(height: 4),
            Text('Motivo: ${solicitud.motivo}'),
            const SizedBox(height: 4),
            Text('Cargo: ${solicitud.cargo}'),
            if (solicitud.coche != null) ...[
              const SizedBox(height: 4),
              Text('Vehículo: ${solicitud.coche}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVehiculoCard(SolicitudChofer coche) {
    final bool estaEnUso = (coche.coche ?? '').contains('(En Uso)');

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Icon(
          Icons.directions_car,
          color: estaEnUso ? Colors.red : Colors.green,
          size: 32,
        ),
        title: Text(
          coche.coche ?? 'Sin descripción',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: estaEnUso ? Colors.red : Colors.black,
          ),
        ),
        subtitle: Text(
          estaEnUso ? 'No Disponible' : 'Disponible',
          style: TextStyle(
            color: estaEnUso ? Colors.red : Colors.green,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: estaEnUso
                ? Colors.red.withOpacity(0.1)
                : Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            estaEnUso ? Icons.lock : Icons.lock_open,
            color: estaEnUso ? Colors.red : Colors.green,
          ),
        ),
      ),
    );
  }

  Future<void> _mostrarFormularioSolicitud(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final motivoController = TextEditingController();
    int? selectedCoche;
    int? selectedTipoSolicitud;
    final DateTime fechaSolicitud = DateTime.now();
    int? estado = 1;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        bool? requiereChofer;

        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            insetPadding: const EdgeInsets.all(16),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: formKey,
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
                                DateFormat('dd/MM/yyyy').format(fechaSolicitud),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Tipo de Solicitud',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          items: _tiposSolicitudes.map((TipoSolicitud tipo) {
                            return DropdownMenuItem<int>(
                              value: tipo.idEs,
                              child: Text(
                                tipo.descripcion ?? '',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedTipoSolicitud = value;
                            });
                          },
                          validator: (value) => value == null
                              ? 'Seleccione un tipo de solicitud'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: motivoController,
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
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Coche para solicitar',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          items: _coches.map((SolicitudChofer coche) {
                            final bool estaEnUso =
                                (coche.coche ?? '').contains('(En Uso)');
                            return DropdownMenuItem<int>(
                              value: coche.idCocheSol,
                              enabled: !estaEnUso,
                              child: Text(
                                coche.coche ?? '',
                                overflow: TextOverflow.ellipsis,
                                style: estaEnUso
                                    ? const TextStyle(
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic,
                                      )
                                    : null,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCoche = value;
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Seleccione un coche' : null,
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('¿Requiere chofer?'),
                          value: requiereChofer ?? false,
                          onChanged: (bool value) {
                            setState(() {
                              requiereChofer = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
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
                              if (formKey.currentState!.validate()) {
                                try {
                                  SolicitudChofer nuevaSolicitud =
                                      SolicitudChofer(
                                    motivo: motivoController.text,
                                    codEmpSoli: userData?.codEmpleado ?? 0,
                                    cargo: userData?.cargo,
                                    estado: estado,
                                    idCocheSol: selectedCoche,
                                    idES: selectedTipoSolicitud,
                                    requiereChofer: (requiereChofer ?? false)
                                        ? 1
                                        : 0, // Convertir boolean a int
                                    audUsuario: userData?.codUsuario ?? 0,
                                  );

                                  await _driverCarService
                                      .registerSolicitudChofer(nuevaSolicitud);
                                  Navigator.pop(context);
                                  _showSuccessSnackBar(
                                      'Solicitud creada con éxito');
                                  await _loadSolicitudes();
                                } catch (e) {
                                  _showErrorSnackBar(
                                      'Error al crear la solicitud: $e');
                                }
                              }
                            },
                            child: const Text(
                              'Guardar Solicitud',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
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
        });
      },
    );
  }
}

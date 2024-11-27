import 'package:billing/application/auth/local_storage_service.dart';
import 'package:billing/application/driver-car/driver-car_service.dart';
import 'package:billing/domain/auth/login.dart';
import 'package:billing/domain/driver-car/EstadoChofer.dart';
import 'package:billing/domain/driver-car/SolicitudChofer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SolicitudChoferScreen extends StatefulWidget {
  const SolicitudChoferScreen({super.key});

  @override
  State<SolicitudChoferScreen> createState() => _SolicitudChoferScreenState();
}

class _SolicitudChoferScreenState extends State<SolicitudChoferScreen> {
  final LocalStorageService _localStorageService = LocalStorageService();
  final DriverCarService _driverCarService = DriverCarService();

  Login? userData;
  List<SolicitudChofer> _solicitudes = [];
  List<EstadoChofer> _estados = [];
  List<SolicitudChofer> _coches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialLoad();
  }

  Future<void> _initialLoad() async {
    await _getUserData();
    await _loadSolicitudes();
    await _loadEstados();
    await _loadCoches();
  }

  Future<void> _getUserData() async {
    userData = await _localStorageService.getUser();
  }

  Future<void> _loadSolicitudes() async {
    try {
      setState(() => _isLoading = true);
      final solicitudes =
          await _driverCarService.obtainSolicitudes(userData?.codEmpleado ?? 0);
      setState(() {
        _solicitudes = solicitudes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error al cargar las solicitudes: $e');
    }
  }

  Future<void> _loadEstados() async {
    try {
      _estados = await _driverCarService.lstEstados();
    } catch (e) {
      _showErrorSnackBar('Error al cargar los estados: $e');
    }
  }

  Future<void> _loadCoches() async {
    try {
      _coches = await _driverCarService.obtainCoches();
    } catch (e) {
      _showErrorSnackBar('Error al cargar los coches: $e');
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
            child: Column(
              children: [
                ListTile(
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
                        backgroundColor:
                            _getEstadoColor(solicitud.estadoCad ?? ''),
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
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /*Future<void> _mostrarFormularioPrestamo(
      BuildContext context, SolicitudChofer solicitud) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return _PrestamoFormDialog(
          solicitud: solicitud,
          userData: userData,
          estados: _estados, // Pasar la lista de estados
          onSuccess: () async {
            Navigator.pop(context);
            _showSuccessSnackBar('Préstamo registrado con éxito');
            await _loadSolicitudes();
          },
          onError: (String message) {
            _showErrorSnackBar(message);
          },
        );
      },
    );
  }*/

  Future<void> _mostrarFormularioSolicitud(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();
    final _motivoController = TextEditingController();
    int? _selectedCoche;
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
                      SizedBox(
                        width: double
                            .infinity, // Asegura que tome el ancho disponible
                        child: DropdownButtonFormField<int>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Coche para solicitar',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          items: _coches.map((SolicitudChofer coche) {
                            final bool estaEnUso = (coche.coche ?? '').contains('(En Uso)');
                            return DropdownMenuItem<int>(
                              value: coche.idCocheSol,
                              enabled: !estaEnUso, // Deshabilita si está en uso
                              child: Text(
                                coche.coche ?? '',
                                overflow: TextOverflow.ellipsis,
                                style: estaEnUso
                                    ? const TextStyle(
                                        color: Colors
                                            .grey, // Color gris para items deshabilitados
                                        fontStyle: FontStyle.italic,
                                      )
                                    : null,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCoche = value;
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Seleccione un coche' : null,
                        ),
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
                            if (_formKey.currentState!.validate()) {
                              try {
                                SolicitudChofer nuevaSolicitud =
                                    SolicitudChofer(
                                  motivo: _motivoController.text,
                                  codEmpSoli: userData?.codEmpleado ?? 0,
                                  cargo: userData?.cargo,
                                  estado: _estado,
                                  idCocheSol:
                                      _selectedCoche, // Usar la variable directamente // Agregar este campo
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

/*class _PrestamoFormDialog extends StatefulWidget {
  final SolicitudChofer solicitud;
  final Login? userData;
  final VoidCallback onSuccess;
  final Function(String) onError;
  final List<EstadoChofer> estados; // Agregar este campo

  const _PrestamoFormDialog({
    required this.solicitud,
    required this.userData,
    required this.onSuccess,
    required this.onError,
    required this.estados, // Agregar este parámetro
  });

  @override
  _PrestamoFormDialogState createState() => _PrestamoFormDialogState();
}*/

/*class _PrestamoFormDialogState extends State<_PrestamoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _driverCarService = DriverCarService();
  final _kmEntregaController = TextEditingController();
  final _nivelCombustibleController = TextEditingController(text: '0');
  final _estadoLateralController = TextEditingController();
  final _estadoInteriorController = TextEditingController();
  final _estadoDelanteraController = TextEditingController();
  final _estadoTraseraController = TextEditingController();
  final _estadoCapoteController = TextEditingController();
  double _nivelCombustible = 0;
  List<int> _selectedLateralEstados = [];
  List<int> _selectedInteriorEstados = [];
  List<int> _selectedDelanteraEstados = [];
  List<int> _selectedTraseraEstados = [];
  List<int> _selectedCapoteEstados = [];

  @override
  Widget build(BuildContext context) {
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
                        'Estado del Vehículo - Entrega',
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

                  // ID Solicitud
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ID Solicitud',
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
                          widget.solicitud.idSolicitud?.toString() ??
                              'No disponible',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Kilometraje
                  TextFormField(
                    controller: _kmEntregaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Kilometraje',
                      border: OutlineInputBorder(),
                      suffixText: 'km',
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16),

                  // Nivel de Combustible con Gauge
                  Container(
                    height: 250,
                    child: SfRadialGauge(
                      enableLoadingAnimation: true,
                      axes: <RadialAxis>[
                        RadialAxis(
                          minimum: 0,
                          maximum: 100,
                          ranges: <GaugeRange>[
                            GaugeRange(
                                startValue: 0, endValue: 33, color: Colors.red),
                            GaugeRange(
                                startValue: 33,
                                endValue: 66,
                                color: Colors.orange),
                            GaugeRange(
                                startValue: 66,
                                endValue: 100,
                                color: Colors.green),
                          ],
                          pointers: <GaugePointer>[
                            MarkerPointer(
                              value: _nivelCombustible,
                              enableDragging: true,
                              onValueChanged: (double value) {
                                setState(() {
                                  _nivelCombustible = value;
                                  _nivelCombustibleController.text =
                                      value.toStringAsFixed(0);
                                });
                              },
                              onValueChangeEnd: (double value) {
                                setState(() {
                                  _nivelCombustible = value;
                                  _nivelCombustibleController.text =
                                      value.toStringAsFixed(0);
                                });
                              },
                              markerHeight: 20,
                              markerWidth: 20,
                              markerType: MarkerType.triangle,
                              color: Colors.blue,
                            ),
                            NeedlePointer(
                              value: _nivelCombustible,
                              enableAnimation: true,
                              needleColor: Colors.blue,
                            ),
                          ],
                          annotations: <GaugeAnnotation>[
                            GaugeAnnotation(
                              widget: Text(
                                '${_nivelCombustible.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              angle: 90,
                              positionFactor: 0.5,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Estados del vehículo
                  const Text(
                    'Estado de la Carrocería',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ExpansionTile(
                      title: Text('Estado Lateral'),
                      children: widget.estados.map((EstadoChofer estado) {
                        return CheckboxListTile(
                          title: Text(estado.estado ?? ''),
                          value: _selectedLateralEstados.contains(estado.idEst),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value ?? false) {
                                _selectedLateralEstados.add(estado.idEst ?? 0);
                              } else {
                                _selectedLateralEstados.remove(estado.idEst);
                              }
                              _estadoLateralController.text =
                                  _selectedLateralEstados.join(',');
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ExpansionTile(
                      title: Text('Estado Interior'),
                      children: widget.estados.map((EstadoChofer estado) {
                        return CheckboxListTile(
                          title: Text(estado.estado ?? ''),
                          value: _selectedInteriorEstados.contains(estado.idEst),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value ?? false) {
                                _selectedInteriorEstados.add(estado.idEst ?? 0);
                              } else {
                                _selectedInteriorEstados.remove(estado.idEst);
                              }
                              _estadoInteriorController.text =
                                  _selectedInteriorEstados.join(',');
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ExpansionTile(
                      title: Text('Estado Delantera'),
                      children: widget.estados.map((EstadoChofer estado) {
                        return CheckboxListTile(
                          title: Text(estado.estado ?? ''),
                          value: _selectedDelanteraEstados.contains(estado.idEst),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value ?? false) {
                                _selectedDelanteraEstados.add(estado.idEst ?? 0);
                              } else {
                                _selectedDelanteraEstados.remove(estado.idEst);
                              }
                              _estadoDelanteraController.text =
                                  _selectedDelanteraEstados.join(',');
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ExpansionTile(
                      title: Text('Estado Trasera'),
                      children: widget.estados.map((EstadoChofer estado) {
                        return CheckboxListTile(
                          title: Text(estado.estado ?? ''),
                          value: _selectedTraseraEstados.contains(estado.idEst),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value ?? false) {
                                _selectedTraseraEstados.add(estado.idEst ?? 0);
                              } else {
                                _selectedTraseraEstados.remove(estado.idEst);
                              }
                              _estadoTraseraController.text =
                                  _selectedTraseraEstados.join(',');
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ExpansionTile(
                      title: Text('Estado Capote'),
                      children: widget.estados.map((EstadoChofer estado) {
                        return CheckboxListTile(
                          title: Text(estado.estado ?? ''),
                          value: _selectedCapoteEstados.contains(estado.idEst),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value ?? false) {
                                _selectedCapoteEstados.add(estado.idEst ?? 0);
                              } else {
                                _selectedCapoteEstados.remove(estado.idEst);
                              }
                              _estadoCapoteController.text =
                                  _selectedCapoteEstados.join(',');
                            });
                          },
                        );
                      }).toList(),
                    ),
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
                            PrestamoChofer prestamoData = PrestamoChofer(
                                idSolicitud: widget.solicitud.idSolicitud,
                                idCoche: widget
                                    .solicitud.idCocheSol, // Agregar esta línea
                                codEmpEntregadoPor:
                                    widget.userData?.codEmpleado ?? 0,
                                kilometrajeEntrega:
                                    double.parse(_kmEntregaController.text),
                                nivelCombustibleEntrega:
                                    _nivelCombustible.round(),
                                estadoLateralesEntrega:
                                    int.parse(_estadoLateralController.text),
                                estadoInteriorEntrega:
                                    int.parse(_estadoInteriorController.text),
                                estadoDelanteraEntrega:
                                    int.parse(_estadoDelanteraController.text),
                                estadoTraseraEntrega:
                                    int.parse(_estadoTraseraController.text),
                                estadoCapoteEntrega:
                                    int.parse(_estadoCapoteController.text),
                                audUsuario: widget.userData?.codUsuario ?? 0);

                            await _driverCarService
                                .registerPrestamo(prestamoData);

                            widget.onSuccess();
                          } catch (e) {
                            widget
                                .onError('Error al registrar el préstamo: $e');
                          }
                        }
                      },
                      child: const Text(
                        'Registrar Préstamo',
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
  }
}*/

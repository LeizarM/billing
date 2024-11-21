import 'package:billing/application/auth/local_storage_service.dart';
import 'package:billing/application/driver-car/driver-car_service.dart';
import 'package:billing/domain/auth/login.dart';
import 'package:billing/domain/driver-car/PrestamoChofer.dart';
import 'package:billing/domain/driver-car/SolicitudChofer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class DriverViewCarScreen extends StatefulWidget {
  const DriverViewCarScreen({super.key});

  @override
  State<DriverViewCarScreen> createState() => _DriverViewCarScreenState();
}

class _DriverViewCarScreenState extends State<DriverViewCarScreen> {
  final LocalStorageService _localStorageService = LocalStorageService();
  final DriverCarService _driverCarService = DriverCarService();

  Login? userData;
  List<PrestamoChofer>? prestamosSolicitudes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialLoad();
  }

  Future<void> _initialLoad() async {
    setState(() => _isLoading = true);
    await _getUserData();
    await _getPrestamosSolicitudes();
    setState(() => _isLoading = false);
  }

  Future<void> _getUserData() async {
    userData = await _localStorageService.getUser();
    debugPrint('User data: ${userData?.codSucursal}');
  }

  Future<void> _getPrestamosSolicitudes() async {
    prestamosSolicitudes = await _driverCarService
        .lstSolicitudesPretamos(userData?.codSucursal ?? 0);
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

  Future<void> _handleAprobarPrestamo(PrestamoChofer prestamo) async {
    SolicitudChofer _temp = SolicitudChofer();
    _temp.idSolicitud = prestamo.idSolicitud;
    _temp.estado = 2; // Aprobada
    _temp.audUsuario = userData?.codUsuario ?? 0;

    try {
      await _driverCarService.actualizarSolicitud(_temp);
      _showSuccessSnackBar('Préstamo aprobado con éxito');
      await _initialLoad();
    } catch (e) {
      _showErrorSnackBar('Error al aprobar el préstamo: $e');
    }
  }

  Future<void> _handleRechazarPrestamo(PrestamoChofer prestamo) async {
    SolicitudChofer _temp = SolicitudChofer();
    _temp.idSolicitud = prestamo.idSolicitud;
    _temp.estado = 3; // Rechazada
    _temp.audUsuario = userData?.codUsuario ?? 0;

    try {
      await _driverCarService.actualizarSolicitud(_temp);
      _showSuccessSnackBar('Préstamo rechazado');
      await _initialLoad();
    } catch (e) {
      _showErrorSnackBar('Error al rechazar el préstamo: $e');
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'No Disponible - En Uso':
        return Colors.red;
      case 'Disponible - Pendiente Aprobación':
        return Colors.orange;
      case 'Aprobado - Pendiente Entrega':
        return Colors.blue;
      case 'Aprobado - En Uso - Pendiente Devolución':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Préstamos'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initialLoad,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (prestamosSolicitudes == null || prestamosSolicitudes!.isEmpty) {
      return const Center(
        child: Text(
          'No hay préstamos registrados',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _initialLoad,
      child: ListView.builder(
        itemCount: prestamosSolicitudes!.length,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          final prestamo = prestamosSolicitudes![index];
          return Card(
 elevation: 3,
 margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
 child: Column(
   crossAxisAlignment: CrossAxisAlignment.start,
   children: [
     Padding(
       padding: const EdgeInsets.all(16),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           // Modelo y placa del vehículo
           Text(
             prestamo.coche?.split(';')[0].trim() ?? 'Sin vehículo asignado',
             style: const TextStyle(
               fontWeight: FontWeight.bold,
               fontSize: 16,
             ),
           ),
           const SizedBox(height: 4),
           Text(
             prestamo.coche?.split(';')[1].trim() ?? '',
             style: TextStyle(
               fontSize: 14,
               color: Colors.grey[600],
             ),
           ),
           const SizedBox(height: 8),
           
           // Chip de estado
           Chip(
             label: Text(
               prestamo.estadoDisponibilidad ?? 'N/A',
               style: const TextStyle(color: Colors.white),
             ),
             backgroundColor: _getEstadoColor(prestamo.estadoDisponibilidad ?? ''),
           ),

           // Información adicional
           const SizedBox(height: 16),
           Row(
             children: [
               const Icon(Icons.calendar_today, size: 16),
               const SizedBox(width: 8),
               Text('Fecha: ${prestamo.fechaSolicitud != null ? DateFormat('dd/MM/yyyy HH:mm').format(prestamo.fechaSolicitud!) : 'No disponible'}'),
             ],
           ),
           const SizedBox(height: 8),
           Row(
             children: [
               const Icon(Icons.person, size: 16),
               const SizedBox(width: 8),
               Expanded(
                 child: Text('Solicitante: ${prestamo.solicitante ?? 'No disponible'}'),
               ),
             ],
           ),
           const SizedBox(height: 8),
           Row(
             children: [
               const Icon(Icons.work, size: 16),
               const SizedBox(width: 8),
               Text('Cargo: ${prestamo.cargo ?? 'No disponible'}'),
             ],
           ),
           const SizedBox(height: 8),
           Row(
             children: [
               const Icon(Icons.description, size: 16),
               const SizedBox(width: 8),
               Expanded(
                 child: Text('Motivo: ${prestamo.motivo ?? 'No disponible'}'),
               ),
             ],
           ),
           if (prestamo.kilometrajeEntrega != 0)
             Padding(
               padding: const EdgeInsets.only(top: 8),
               child: Row(
                 children: [
                   const Icon(Icons.speed, size: 16),
                   const SizedBox(width: 8),
                   Text('Kilometraje: ${prestamo.kilometrajeEntrega.toString()} km'),
                 ],
               ),
             ),
           if (prestamo.nivelCombustibleEntrega != 0)
             Padding(
               padding: const EdgeInsets.only(top: 8),
               child: Row(
                 children: [
                   const Icon(Icons.local_gas_station, size: 16),
                   const SizedBox(width: 8),
                   Text('Nivel de Combustible: ${prestamo.nivelCombustibleEntrega.toString()}%'),
                 ],
               ),
             ),
         ],
       ),
     ),

     // Botones de acción
     if (prestamo.estadoDisponibilidad == 'No Disponible - En Uso' ||
         prestamo.estadoDisponibilidad == 'Disponible - Pendiente Aprobación')
       Padding(
         padding: const EdgeInsets.all(16),
         child: Row(
           children: [
             Expanded(
               child: ElevatedButton.icon(
                 icon: const Icon(Icons.check_circle, color: Colors.white),
                 label: const Text(
                   'Aprobar',
                   style: TextStyle(color: Colors.white),
                 ),
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.green,
                   padding: const EdgeInsets.symmetric(vertical: 12),
                 ),
                 onPressed: () => _handleAprobarPrestamo(prestamo),
               ),
             ),
             const SizedBox(width: 8),
             Expanded(
               child: ElevatedButton.icon(
                 icon: const Icon(Icons.cancel, color: Colors.white),
                 label: const Text(
                   'Rechazar',
                   style: TextStyle(color: Colors.white),
                 ),
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.red,
                   padding: const EdgeInsets.symmetric(vertical: 12),
                 ),
                 onPressed: () => _handleRechazarPrestamo(prestamo),
               ),
             ),
           ],
         ),
       ),

     if (prestamo.estadoDisponibilidad == 'Aprobado - Pendiente Entrega' ||
         prestamo.estadoDisponibilidad == 'Aprobado - En Uso - Pendiente Devolución')
       Padding(
         padding: const EdgeInsets.all(16),
         child: SizedBox(
           width: double.infinity,
           child: ElevatedButton.icon(
             icon: const Icon(Icons.car_rental, color: Colors.white),
             label: const Text(
               'Registrar Devolución',
               style: TextStyle(color: Colors.white),
             ),
             style: ElevatedButton.styleFrom(
               backgroundColor: Colors.blue,
               padding: const EdgeInsets.symmetric(vertical: 12),
             ),
             onPressed: () => _mostrarFormularioDevolucion(context, prestamo),
           ),
         ),
       ),
   ],
 ),
);
        },
      ),
    );
  }

  Future<void> _mostrarFormularioDevolucion(
      BuildContext context, PrestamoChofer prestamo) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return _DevolucionFormDialog(
          prestamo: prestamo,
          userData: userData,
          onSuccess: () async {
            Navigator.pop(context);
            _showSuccessSnackBar('Devolución registrada con éxito');
            await _initialLoad();
          },
          onError: (String message) {
            _showErrorSnackBar(message);
          },
        );
      },
    );
  }
}
class _DevolucionFormDialog extends StatefulWidget {
  final PrestamoChofer prestamo;
  final Login? userData;
  final VoidCallback onSuccess;
  final Function(String) onError;

  const _DevolucionFormDialog({
    required this.prestamo,
    required this.userData,
    required this.onSuccess,
    required this.onError,
  });

  @override
  _DevolucionFormDialogState createState() => _DevolucionFormDialogState();
}

class _DevolucionFormDialogState extends State<_DevolucionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _driverCarService = DriverCarService();
  final _kmRecepcionController = TextEditingController();
  final _nivelCombustibleController = TextEditingController(text: '0');
  double _nivelCombustible = 0;

  // Controladores para los estados
  final _estadoLateralController = TextEditingController();
  final _estadoInteriorController = TextEditingController();
  final _estadoDelanteraController = TextEditingController();
  final _estadoTraseraController = TextEditingController();
  final _estadoCapoteController = TextEditingController();

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
                        'Devolución de Vehículo',
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

                  // Información del vehículo
                  Text(
                    'Vehículo: ${widget.prestamo.coche}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  // Kilometraje
                  TextFormField(
                    controller: _kmRecepcionController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Kilometraje de Recepción',
                      border: OutlineInputBorder(),
                      suffixText: 'km',
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Campo requerido' : null,
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
                            GaugeRange(startValue: 0, endValue: 33, color: Colors.red),
                            GaugeRange(startValue: 33, endValue: 66, color: Colors.orange),
                            GaugeRange(startValue: 66, endValue: 100, color: Colors.green),
                          ],
                          pointers: <GaugePointer>[
                            MarkerPointer(
                              value: _nivelCombustible,
                              enableDragging: true,
                              onValueChanged: (double value) {
                                setState(() {
                                  _nivelCombustible = value;
                                  _nivelCombustibleController.text = value.toStringAsFixed(0);
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

                  // Estado Lateral
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Estado Lateral',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Bueno')),
                      DropdownMenuItem(value: 2, child: Text('Regular')),
                      DropdownMenuItem(value: 3, child: Text('Malo')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _estadoLateralController.text = value.toString();
                      });
                    },
                    validator: (value) => value == null ? 'Seleccione un estado' : null,
                  ),
                  const SizedBox(height: 16),

                  // Estado Interior
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Estado Interior',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Bueno')),
                      DropdownMenuItem(value: 2, child: Text('Regular')),
                      DropdownMenuItem(value: 3, child: Text('Malo')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _estadoInteriorController.text = value.toString();
                      });
                    },
                    validator: (value) => value == null ? 'Seleccione un estado' : null,
                  ),
                  const SizedBox(height: 16),

                  // Estado Delantera
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Estado Delantera',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Bueno')),
                      DropdownMenuItem(value: 2, child: Text('Regular')),
                      DropdownMenuItem(value: 3, child: Text('Malo')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _estadoDelanteraController.text = value.toString();
                      });
                    },
                    validator: (value) => value == null ? 'Seleccione un estado' : null,
                  ),
                  const SizedBox(height: 16),

                  // Estado Trasera
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Estado Trasera',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Bueno')),
                      DropdownMenuItem(value: 2, child: Text('Regular')),
                      DropdownMenuItem(value: 3, child: Text('Malo')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _estadoTraseraController.text = value.toString();
                      });
                    },
                    validator: (value) => value == null ? 'Seleccione un estado' : null,
                  ),
                  const SizedBox(height: 16),

                  // Estado Capote
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Estado Capote',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Bueno')),
                      DropdownMenuItem(value: 2, child: Text('Regular')),
                      DropdownMenuItem(value: 3, child: Text('Malo')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _estadoCapoteController.text = value.toString();
                      });
                    },
                    validator: (value) => value == null ? 'Seleccione un estado' : null,
                  ),
                  const SizedBox(height: 24),

                  // Botón de guardar
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
                            PrestamoChofer devolucionData = PrestamoChofer(
                              idSolicitud: widget.prestamo.idSolicitud,
                              kilometrajeRecepcion: double.parse(_kmRecepcionController.text),
                              nivelCombustibleRecepcion: _nivelCombustible.round(),
                              estadoLateralRecepcion: int.parse(_estadoLateralController.text),
                              estadoInteriorRecepcion: int.parse(_estadoInteriorController.text),
                              estadoDelanteraRecepcion: int.parse(_estadoDelanteraController.text),
                              estadoTraseraRecepcion: int.parse(_estadoTraseraController.text),
                              estadoCapoteRecepcion: int.parse(_estadoCapoteController.text),
                              audUsuario: widget.userData?.codUsuario ?? 0,
                            );

                           // await _driverCarService.registrarDevolucion(devolucionData);
                            widget.onSuccess();
                          } catch (e) {
                            widget.onError('Error al registrar la devolución: $e');
                          }
                        }
                      },
                      child: const Text(
                        'Registrar Devolución',
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
}
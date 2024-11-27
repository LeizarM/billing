import 'package:billing/application/auth/local_storage_service.dart';
import 'package:billing/application/driver-car/driver-car_service.dart';
import 'package:billing/domain/auth/login.dart';
import 'package:billing/domain/driver-car/EstadoChofer.dart';
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
  List<EstadoChofer> _estados = [];

  @override
  void initState() {
    super.initState();
    _initialLoad();
  }

  Future<void> _initialLoad() async {
    setState(() => _isLoading = true);
    await _getUserData();
    await _getPrestamosSolicitudes();
    await _loadEstados();
    setState(() => _isLoading = false);
  }

  Future<void> _getUserData() async {
    userData = await _localStorageService.getUser();
  }

  Future<void> _getPrestamosSolicitudes() async {
    prestamosSolicitudes = await _driverCarService.lstSolicitudesPretamos(userData?.codSucursal ?? 0);
  }

  Future<void> _loadEstados() async {
    try {
      _estados = await _driverCarService.lstEstados();
    } catch (e) {
      _showErrorSnackBar('Error al cargar los estados: $e');
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
                        prestamo.coche?.split(';')[0].trim() ??
                            'Sin vehículo asignado',
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
                        backgroundColor: _getEstadoColor(
                            prestamo.estadoDisponibilidad ?? ''),
                      ),

                      // Información adicional
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 8),
                          Text(
                              'Fecha: ${prestamo.fechaSolicitud != null ? DateFormat('dd/MM/yyyy HH:mm').format(prestamo.fechaSolicitud!) : 'No disponible'}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                                'Solicitante: ${prestamo.solicitante ?? 'No disponible'}'),
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
                            child: Text(
                                'Motivo: ${prestamo.motivo ?? 'No disponible'}'),
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
                              Text(
                                  'Kilometraje: ${prestamo.kilometrajeEntrega.toString()} km'),
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
                              Text(
                                  'Nivel de Combustible: ${prestamo.nivelCombustibleEntrega.toString()}%'),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Botones de acción
                if (prestamo.estadoDisponibilidad == 'No Disponible - En Uso' ||
                    prestamo.estadoDisponibilidad ==
                        'Disponible - Pendiente Aprobación')
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.check_circle,
                                color: Colors.white),
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

                if ( prestamo.estadoDisponibilidad =='Aprobado - En Uso - Pendiente Devolución' )
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
                        onPressed: () =>
                            _mostrarFormularioDevolucion(context, prestamo),
                      ),
                    ),
                  ),
                if ( prestamo.estadoDisponibilidad == 'Aprobado - Pendiente Entrega' )
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.car_rental, color: Colors.white),
                        label: const Text(
                          'Registrar Entrega',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () =>
                            _mostrarFormularioPrestamo(context, prestamo),
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

  Future<void> _mostrarFormularioPrestamo(
      BuildContext context, PrestamoChofer prestamo) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return _PrestamoFormDialog(
          prestamo: prestamo,
          userData: userData,
          estados: _estados,
          onSuccess: () async {
            Navigator.pop(context);
            _showSuccessSnackBar('Préstamo registrado con éxito');
            await _initialLoad();
          },
          onError: (String message) {
            _showErrorSnackBar(message);
          },
        );
      },
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
          estados: _estados, // Pasar la lista de estados
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
  final List<EstadoChofer> estados; // Añadir este campo

  const _DevolucionFormDialog({
    required this.prestamo,
    required this.userData,
    required this.onSuccess,
    required this.onError,
    required this.estados, // Añadir este parámetro
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

  // Listas para almacenar los valores seleccionados
  List<int> _estadoLateralValues = [];
  List<int> _estadoInteriorValues = [];
  List<int> _estadoDelanteraValues = [];
  List<int> _estadoTraseraValues = [];
  List<int> _estadoCapoteValues = [];

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
                  // MultiSelect Dropdowns para estados
                  MultiSelectDropdown(
                    label: 'Estado Lateral',
                    items: widget.estados,
                    selectedValues: _estadoLateralValues,
                    onChanged: (values) {
                      setState(() => _estadoLateralValues = values);
                    },
                  ),
                  const SizedBox(height: 16),

                  MultiSelectDropdown(
                    label: 'Estado Interior',
                    items: widget.estados,
                    selectedValues: _estadoInteriorValues,
                    onChanged: (values) {
                      setState(() => _estadoInteriorValues = values);
                    },
                  ),
                  const SizedBox(height: 16),

                  MultiSelectDropdown(
                    label: 'Estado Delantera',
                    items: widget.estados,
                    selectedValues: _estadoDelanteraValues,
                    onChanged: (values) {
                      setState(() => _estadoDelanteraValues = values);
                    },
                  ),
                  const SizedBox(height: 16),

                  MultiSelectDropdown(
                    label: 'Estado Trasera',
                    items: widget.estados,
                    selectedValues: _estadoTraseraValues,
                    onChanged: (values) {
                      setState(() => _estadoTraseraValues = values);
                    },
                  ),
                  const SizedBox(height: 16),

                  MultiSelectDropdown(
                    label: 'Estado Capote',
                    items: widget.estados,
                    selectedValues: _estadoCapoteValues,
                    onChanged: (values) {
                      setState(() => _estadoCapoteValues = values);
                    },
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
                              idPrestamo: widget.prestamo.idPrestamo,
                              idSolicitud: widget.prestamo.idSolicitud,
                              kilometrajeRecepcion:
                                  double.parse(_kmRecepcionController.text),
                              nivelCombustibleRecepcion:
                                  _nivelCombustible.round(),
                              estadoLateralRecepcionAux: _estadoLateralValues.join(','),
                              estadoInteriorRecepcionAux: _estadoInteriorValues.join(','),
                              estadoDelanteraRecepcionAux: _estadoDelanteraValues.join(','),
                              estadoTraseraRecepcionAux: _estadoTraseraValues.join(','),
                              estadoCapoteRecepcionAux: _estadoCapoteValues.join(','),
                              audUsuario: widget.userData?.codUsuario ?? 0,
                            );

                          
                            //TODO: Realizar la llamada al driver car service para registrar la devolución del vehículo
                            await _driverCarService.registerPrestamo(devolucionData);
                            
                            widget.onSuccess();
                          } catch (e) {
                            widget.onError(
                                'Error al registrar la devolución: $e');
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

class _PrestamoFormDialog extends StatefulWidget {
  final PrestamoChofer prestamo;
  final Login? userData;
  final VoidCallback onSuccess;
  final Function(String) onError;
  final List<EstadoChofer> estados;

  const _PrestamoFormDialog({
    required this.prestamo,
    required this.userData,
    required this.onSuccess,
    required this.onError,
    required this.estados,
  });

  @override
  _PrestamoFormDialogState createState() => _PrestamoFormDialogState();
}

class _PrestamoFormDialogState extends State<_PrestamoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _driverCarService = DriverCarService();
  final _kmEntregaController = TextEditingController();
  final _nivelCombustibleController = TextEditingController(text: '0');
  
  // Listas para almacenar los valores seleccionados
  List<int> _estadoLateralValues = [];
  List<int> _estadoInteriorValues = [];
  List<int> _estadoDelanteraValues = [];
  List<int> _estadoTraseraValues = [];
  List<int> _estadoCapoteValues = [];


  double _nivelCombustible = 0;

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
                          widget.prestamo.idSolicitud?.toString() ?? 'No disponible',
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

                  MultiSelectDropdown(
                    label: 'Estado Lateral',
                    items: widget.estados,
                    selectedValues: _estadoLateralValues,
                    onChanged: (values) {
                      setState(() => _estadoLateralValues = values);
                    },
                  ),
                  const SizedBox(height: 16),

                  MultiSelectDropdown(
                    label: 'Estado Interior',
                    items: widget.estados,
                    selectedValues: _estadoInteriorValues,
                    onChanged: (values) {
                      setState(() => _estadoInteriorValues = values);
                    },
                  ),
                  const SizedBox(height: 16),

                  MultiSelectDropdown(
                    label: 'Estado Delantera',
                    items: widget.estados,
                    selectedValues: _estadoDelanteraValues,
                    onChanged: (values) {
                      setState(() => _estadoDelanteraValues = values);
                    },
                  ),
                  const SizedBox(height: 16),

                  MultiSelectDropdown(
                    label: 'Estado Trasera',
                    items: widget.estados,
                    selectedValues: _estadoTraseraValues,
                    onChanged: (values) {
                      setState(() => _estadoTraseraValues = values);
                    },
                  ),
                  
                  const SizedBox(height: 16),

                  MultiSelectDropdown(
                    label: 'Estado Capote',
                    items: widget.estados,
                    selectedValues: _estadoCapoteValues,
                    onChanged: (values) {
                      setState(() => _estadoCapoteValues = values);
                    },
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
                              idSolicitud: widget.prestamo.idSolicitud,
                              idCoche: widget.prestamo.idCoche,
                              codEmpEntregadoPor: widget.userData?.codEmpleado ?? 0,
                              kilometrajeEntrega: double.parse(_kmEntregaController.text),
                              nivelCombustibleEntrega: _nivelCombustible.round(),
                              estadoLateralesEntregaAux: _estadoLateralValues.join(','),
                              estadoInteriorEntregaAux: _estadoInteriorValues.join(','),
                              estadoDelanteraEntregaAux: _estadoDelanteraValues.join(','),
                              estadoTraseraEntregaAux: _estadoTraseraValues.join(','),
                              estadoCapoteEntregaAux: _estadoCapoteValues.join(','),
                              audUsuario: widget.userData?.codUsuario ?? 0
                            );

                            
                            

                            //TODO: Agregar la llamada al service para registrar el préstamo
                            await _driverCarService.registerPrestamo(prestamoData);
                            widget.onSuccess();
                          } catch (e) {
                            widget.onError('Error al registrar el préstamo: $e');
                          }
                        }
                      },
                      child: const Text(
                        'Registrar Entrega',
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

// Primero, creamos un widget personalizado para el dropdown multiselección
class MultiSelectDropdown extends StatefulWidget {
  final String label;
  final List<EstadoChofer> items;
  final Function(List<int>) onChanged;
  final List<int> selectedValues;

  const MultiSelectDropdown({
    Key? key,
    required this.label,
    required this.items,
    required this.onChanged,
    required this.selectedValues,
  }) : super(key: key);

  @override
  _MultiSelectDropdownState createState() => _MultiSelectDropdownState();
}

class _MultiSelectDropdownState extends State<MultiSelectDropdown> {
  @override
  Widget build(BuildContext context) {
    return FormField<List<int>>(
      initialValue: widget.selectedValues,
      validator: (value) =>
          value == null || value.isEmpty ? 'Seleccione al menos un estado' : null,
      builder: (FormFieldState<List<int>> state) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: widget.label,
            errorText: state.errorText,
            border: const OutlineInputBorder(),
          ),
          child: InkWell(
            onTap: () async {
              final List<int>? results = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return MultiSelectDialog(
                    items: widget.items,
                    initialSelectedValues: widget.selectedValues,
                  );
                },
              );
              if (results != null) {
                state.didChange(results);
                widget.onChanged(results);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                widget.selectedValues.isEmpty
                    ? 'Seleccionar ${widget.label}'
                    : widget.selectedValues
                        .map((id) => widget.items
                            .firstWhere((item) => item.idEst == id)
                            .estado)
                        .join(', '),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Diálogo para selección múltiple
class MultiSelectDialog extends StatefulWidget {
  final List<EstadoChofer> items;
  final List<int> initialSelectedValues;

  const MultiSelectDialog({
    Key? key,
    required this.items,
    required this.initialSelectedValues,
  }) : super(key: key);

  @override
  _MultiSelectDialogState createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  late List<int> _selectedValues;

  @override
  void initState() {
    super.initState();
    _selectedValues = List.from(widget.initialSelectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar Estados'),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.items.map((item) {
            return CheckboxListTile(
              value: _selectedValues.contains(item.idEst),
              title: Text(item.estado ?? ''),
              onChanged: (bool? checked) {
                setState(() {
                  if (checked == true) {
                    _selectedValues.add(item.idEst!);
                  } else {
                    _selectedValues.remove(item.idEst);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: const Text('Aceptar'),
          onPressed: () => Navigator.pop(context, _selectedValues),
        ),
      ],
    );
  }
}
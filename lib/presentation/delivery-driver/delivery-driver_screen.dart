import 'package:billing/application/auth/local_storage_service.dart';
import 'package:billing/application/delivery-driver/delivery-driver_service.dart';
import 'package:billing/application/delivery-driver/location_service.dart';
import 'package:billing/domain/auth/login.dart';
import 'package:billing/domain/delivery-driver/deliverDriver.dart';
import 'package:billing/domain/delivery-driver/groupedDelivery.dart';
import 'package:billing/presentation/delivery-driver/widgets/customLoadingIndicator.dart';
import 'package:billing/presentation/delivery-driver/widgets/groupedDelivery.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class DeliveryDriverScreen extends StatefulWidget {
  const DeliveryDriverScreen({super.key});

  @override
  State<DeliveryDriverScreen> createState() => _DeliveryDriverScreenState();
}

class _DeliveryDriverScreenState extends State<DeliveryDriverScreen> {
  final LocalStorageService _localStorageService = LocalStorageService();
  final DeliveryDriverService _deliveryDriverService = DeliveryDriverService();
  final LocationService _locationService = LocationService();
  List<GroupedDelivery>? _groupedDeliveries;
  bool _isLoading = true;
  bool _isGettingLocation = false;
  Login? userData;
  late Color _primaryColor;
  final Color _secondaryColor = Colors.green;
  late Color _tertiaryColor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _primaryColor = Theme.of(context).primaryColor;
    _tertiaryColor = Theme.of(context).colorScheme.secondary;
  }

  @override
  void initState() {
    super.initState();
    _loadDeliveries();
  }

  Future<void> _loadDeliveries() async {
    setState(() {
      _isLoading = true;
    });

    try {
      userData = await _localStorageService.getUser();
      if (userData != null) {
        final deliveries = await _deliveryDriverService.obtainDelivery(13);
        _groupDeliveries(deliveries);
      } else {
        print('User data or employee code is null');
      }
    } catch (e) {
      print('Error loading deliveries: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar las entregas: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _groupDeliveries(List<DeliveryDriver> deliveries) {
    final grouped = groupBy(deliveries, (DeliveryDriver d) => d.docEntry);
    _groupedDeliveries = grouped.entries.map((entry) {
      final items = entry.value;
      final db = items.first.db!; // Obtenemos el db del primer item
      return GroupedDelivery(
        docEntry: entry.key!,
        cardName: items.first.cardName!,
        docDate: DateTime.parse(items.first.docDate.toString()),
        addressEntregaMat: items.first.addressEntregaMat!,
        items: items,
        db: db, // Pasamos el db al constructor
      );
    }).toList();
  }

  Future<void> _markAsDelivered(GroupedDelivery delivery) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar entrega'),
          content: const Text(
              '¿Estás seguro de que quieres marcar esta entrega como completada?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Confirmar'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _isGettingLocation = true;
      });

      try {
        // Verificar y solicitar permisos de ubicación
        bool permissionGranted =
            await _locationService.checkAndRequestLocationPermissions(context);
        if (!permissionGranted) {
          setState(() {
            _isGettingLocation = false;
          });
          return;
        }

        Position? position = await _locationService.getCurrentPosition();
        if (position == null) {
          throw Exception('No se pudo obtener la posición.');
        }

        // Obtener la dirección usando la API de Nominatim con Dio
        String address = await _locationService.getAddressFromLatLng(
          position.latitude,
          position.longitude,
        );

        String currentDateTime =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

        // Guardar los datos de la entrega
        await _saveDeliveryData(
            docEntry: delivery.docEntry,
            db: delivery.db,
            latitude: position.latitude,
            longitude: position.longitude,
            address: address,
            dateTime: currentDateTime,
            audUsuario: userData!.codUsuario);

        // Actualizar el estado de la entrega localmente (opcional)
        setState(() {
          delivery.isDelivered = true;
        });

        // Recargar la lista de entregas
        await _loadDeliveries();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Entrega marcada como completada'),
            backgroundColor: _secondaryColor,
          ),
        );
      } catch (e) {
        print('Error al marcar como entregada: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  // Método para guardar los datos de la entrega
  Future<void> _saveDeliveryData(
      {required int docEntry,
      required String db,
      required double latitude,
      required double longitude,
      required String address,
      required String dateTime,
      required int audUsuario}) async {
    try {
      await _deliveryDriverService.saveDeliveryData(
        docEntry: docEntry,
        db: db,
        latitude: latitude,
        longitude: longitude,
        address: address,
        dateTime: dateTime,
        audUsuario: audUsuario,
      );
      print('Datos de la entrega guardados correctamente.');
    } catch (e) {
      print('Error al guardar los datos de la entrega: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar los datos de la entrega'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Método para verificar y solicitar permisos de ubicación
  Future<bool> _checkAndRequestLocationPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si el servicio de ubicación está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El servicio de ubicación está deshabilitado.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Los permisos de ubicación están denegados.'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Los permisos de ubicación están denegados permanentemente.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  // Método para obtener la dirección desde latitud y longitud usando Dio

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Entregas Pendientes'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadDeliveries,
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _groupedDeliveries == null || _groupedDeliveries!.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 64, color: _tertiaryColor),
                          const SizedBox(height: 16),
                          Text(
                            'No hay entregas pendientes',
                            style:
                                TextStyle(fontSize: 18, color: _tertiaryColor),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _groupedDeliveries!.length,
                      itemBuilder: (context, index) {
                        final groupedDelivery = _groupedDeliveries![index];
                        return GroupedDeliveryCard(
                          groupedDelivery: groupedDelivery,
                          primaryColor: _primaryColor,
                          secondaryColor: _secondaryColor,
                          tertiaryColor: _tertiaryColor,
                          onMarkAsDelivered: () =>
                              _markAsDelivered(groupedDelivery),
                        );
                      },
                    ),
        ),
        // Indicador de carga personalizado
        if (_isGettingLocation)
          const CustomLoadingIndicator(
            message: 'Guardando...',
          ),
      ],
    );
  }
}

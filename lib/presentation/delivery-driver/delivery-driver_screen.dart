import 'package:billing/application/auth/local_storage_service.dart';
import 'package:billing/application/delivery-driver/delivery-driver_service.dart';
import 'package:billing/domain/delivery-driver/deliverDriver.dart';
import 'package:billing/domain/delivery-driver/groupedDelivery.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class DeliveryDriverScreen extends StatefulWidget {
  const DeliveryDriverScreen({Key? key}) : super(key: key);

  @override
  State<DeliveryDriverScreen> createState() => _DeliveryDriverScreenState();
}

class _DeliveryDriverScreenState extends State<DeliveryDriverScreen> {
  final LocalStorageService _localStorageService = LocalStorageService();
  final DeliveryDriverService _deliveryDriverService = DeliveryDriverService();
  List<GroupedDelivery>? _groupedDeliveries;
  bool _isLoading = true;
  bool _isGettingLocation = false;

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
      final userData = await _localStorageService.getUser();
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
        bool permissionGranted = await _checkAndRequestLocationPermissions();
        if (!permissionGranted) {
          setState(() {
            _isGettingLocation = false;
          });
          return;
        }

        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );

        // Obtener la dirección usando la API de Nominatim con Dio
        String address = await _getAddressFromLatLng(
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
        );

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
        print('Error getting location: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al obtener la ubicación'),
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
  Future<void> _saveDeliveryData({
    required int docEntry,
    required String db,
    required double latitude,
    required double longitude,
    required String address,
    required String dateTime,
  }) async {
    try {
      await _deliveryDriverService.saveDeliveryData(
        docEntry: docEntry,
        db: db,
        latitude: latitude,
        longitude: longitude,
        address: address,
        dateTime: dateTime,
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
  Future<String> _getAddressFromLatLng(
      double latitude, double longitude) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$latitude&lon=$longitude';

    try {
      Dio dio = Dio();

      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        final address = data['display_name'] as String?;
        return address ?? 'Dirección no disponible';
      } else {
        print('Error al obtener la dirección: ${response.statusCode}');
        return 'Dirección no disponible';
      }
    } catch (e) {
      print('Error al obtener la dirección: $e');
      return 'Dirección no disponible';
    }
  }

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
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ExpansionTile(
                            title: Text(
                              groupedDelivery.cardName,
                              style: TextStyle(
                                  color: _primaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Fecha: ${DateFormat('dd/MM/yyyy').format(groupedDelivery.docDate)}'),
                                Text(
                                    'Total Productos: ${groupedDelivery.totalQuantity}'),
                              ],
                            ),
                            leading: CircleAvatar(
                              backgroundColor: groupedDelivery.isDelivered
                                  ? _secondaryColor
                                  : _primaryColor,
                              child: Icon(
                                groupedDelivery.isDelivered
                                    ? Icons.check
                                    : Icons.local_shipping,
                                color: Colors.white,
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Dirección de entrega:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: _primaryColor),
                                    ),
                                    Text(groupedDelivery.addressEntregaMat),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Productos:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: _primaryColor),
                                    ),
                                    ...groupedDelivery.items.map((item) =>
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                  child:
                                                      Text(item.dscription!)),
                                              Text('Cantidad: ${item.quantity}',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ),
                                        )),
                                    if (!groupedDelivery.isDelivered)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 16.0),
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.check),
                                          label: const Text(
                                              'Marcar como entregado'),
                                          onPressed: () =>
                                              _markAsDelivered(groupedDelivery),
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
        // Indicador de carga personalizado
        if (_isGettingLocation)
          const _CustomLoadingIndicator(
            message: 'Guardando...',
          ),
      ],
    );
  }
}

// Widget personalizado para el indicador de carga
class _CustomLoadingIndicator extends StatelessWidget {
  final String message;

  const _CustomLoadingIndicator({Key? key, required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black38,
      child: Center(
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            // Añadimos sombra para darle profundidad
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Puedes reemplazar esto con una animación personalizada
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

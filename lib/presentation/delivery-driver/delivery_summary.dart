import 'package:billing/application/delivery-driver/delivery-driver_service.dart'; // Asegúrate de importar correctamente
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart'; // Importar url_launcher

import '../../domain/delivery-driver/deliverDriver.dart';

// Función para abrir Google Maps con las coordenadas proporcionadas
Future<void> abrirGoogleMaps(BuildContext context, double latitude, double longitude) async {
  // Esquema geo para aplicaciones de mapas en Android
  final Uri geoUri = Uri.parse('geo:$latitude,$longitude?q=$latitude,$longitude');

  // URL web de Google Maps como respaldo
  final Uri googleMapsWebUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');

  debugPrint('Intentando abrir geoUri: $geoUri');
  // Intentar abrir con el esquema geo
  if (await canLaunchUrl(geoUri)) {
    debugPrint('Abriendo con geoUri');
    await launchUrl(geoUri);
    return;
  } else {
    debugPrint('No se pudo abrir con geoUri');
  }

  debugPrint('Intentando abrir googleMapsWebUri: $googleMapsWebUri');
  // Si falla, intentar abrir con la URL web
  if (await canLaunchUrl(googleMapsWebUri)) {
    debugPrint('Abriendo con googleMapsWebUri');
    await launchUrl(googleMapsWebUri, mode: LaunchMode.externalApplication);
    return;
  } else {
    debugPrint('No se pudo abrir con googleMapsWebUri');
  }

  // Si ambos fallan, mostrar un SnackBar con un mensaje de error
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('No se pudo abrir Google Maps.')),
  );
}

class DeliverySummary extends StatefulWidget {
  const DeliverySummary({super.key});

  @override
  State<DeliverySummary> createState() => _DeliverySummaryState();
}

class _DeliverySummaryState extends State<DeliverySummary> {
  List<DeliveryDriver> drivers = [];
  List<DeliveryDriver> deliveryItems = []; // Entregas que ya fueron entregadas

  DateTime selectedDate = DateTime.now();
  int? selectedDriver; // Nullable y de tipo int
  final dateFormat = DateFormat('dd/MM/yyyy');
  final TextEditingController _dateController = TextEditingController();

  bool isLoadingDeliveries = false; // Variable para indicar carga de entregas

  @override
  void initState() {
    super.initState();
    _dateController.text = dateFormat.format(selectedDate);
    _loadDeliveriesForUser();
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  // Método para cargar los conductores
  Future<void> _loadDeliveriesForUser() async {
    try {
      final response = await DeliveryDriverService().obtainDriver();
      setState(() {
        drivers = response;
        if (drivers.isNotEmpty) {
          selectedDriver = drivers.first.codEmpleado; // Establece el codEmpleado del primer conductor
        }
      });
    } catch (e) {
      debugPrint('Error loading drivers: $e');
      // Mostrar SnackBar con error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar los conductores.')),
      );
    }
  }

  // Método para buscar entregas
  Future<void> _fetchDeliveryItems(int codEmpleado, String fecha) async {
    if (selectedDriver != null) {
      setState(() {
        isLoadingDeliveries = true;
      });
      try {
        final response = await DeliveryDriverService().obtainDeliveriesXEmp(
          codEmpleado,
          fecha,
        );

        // Asignar directamente la respuesta a deliveryItems
        setState(() {
          deliveryItems = response;
          isLoadingDeliveries = false;
        });
      } catch (e) {
        debugPrint('Error loading delivery items: $e');
        setState(() {
          isLoadingDeliveries = false;
        });
        // Mostrar SnackBar con error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar las entregas.')),
        );
      }
    }
  }

  // Método para seleccionar la fecha
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2070),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            iconButtonTheme: IconButtonThemeData(
              style: IconButton.styleFrom(
                foregroundColor: Colors.transparent,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = dateFormat.format(picked);
      });
    }
  }

  // Método para manejar la búsqueda al presionar el ícono
  void _onSearchPressed() {
    if (selectedDriver == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un conductor.')),
      );
      return;
    }

    // Formatear la fecha seleccionada en "yyyy-MM-dd"
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    // Imprimir la fecha formateada y el codEmpleado seleccionado
    debugPrint('Fecha seleccionada: $formattedDate');
    debugPrint('Cod Empleado seleccionado: $selectedDriver');

    // Implementa aquí la lógica de búsqueda utilizando selectedDriver y formattedDate
    // Por ejemplo, realizar una llamada a una API con estos parámetros
    _fetchDeliveryItems(selectedDriver!, formattedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text(
          'REGISTRO DE ENTREGAS',
          style: TextStyle(fontSize: 16),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Contenedor para los campos de búsqueda (fecha y conductor)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0), // Reducido el padding horizontal
            child: Column(
              children: [
                // Campo de fecha
                TextField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true, // Reduce el padding vertical
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8, // Reducido el padding horizontal
                      vertical: 8,
                    ),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today, size: 20),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 16),
                // Fila de conductor y botón de búsqueda (icono)
                Row(
                  children: [
                    // Dropdown para seleccionar conductor
                    Flexible(
                      fit: FlexFit.tight,
                      child: DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          isDense: true, // Reduce el padding vertical
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8, // Reducido el padding horizontal
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                        value: selectedDriver,
                        items: drivers.map((DeliveryDriver driver) {
                          return DropdownMenuItem<int>(
                            value: driver.codEmpleado, // Usar codEmpleado como valor
                            child: Text(
                              driver.nombreCompleto ?? 'Sin nombre', // Mostrar nombreCompleto como etiqueta
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis, // Manejar desbordamiento
                            ),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedDriver = newValue;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Icono de búsqueda con Tooltip
                    Tooltip(
                      message: 'Buscar',
                      child: IconButton(
                        icon: const Icon(Icons.search, color: Colors.blue),
                        iconSize: 28, // Tamaño del ícono ajustado
                        onPressed: _onSearchPressed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Área para mostrar la lista de entregas
          Expanded(
            child: isLoadingDeliveries
                ? const Center(child: CircularProgressIndicator()) // Indicador de carga mientras se buscan entregas
                : deliveryItems.isEmpty
                    ? drivers.isEmpty
                        ? const Center(child: CircularProgressIndicator()) // Indicador de carga si no hay conductores
                        : const Center(child: Text('No hay entregas para mostrar.')) // Mensaje si no hay entregas
                    : ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: deliveryItems.length,
                        itemBuilder: (context, index) {
                          final item = deliveryItems[index];
                          return DeliveryCard(item: item);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class DeliveryCard extends StatelessWidget {
  final DeliveryDriver item;

  const DeliveryCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // Determinar el color basado en el estado ('obs')
    Color estadoColor;
    switch (item.obs?.toLowerCase()) {
      case 'en proceso':
        estadoColor = Colors.orange;
        break;
      case 'finalizando entregas':
        estadoColor = Colors.green;
        break;
      case 'iniciando entregas':
        estadoColor = Colors.blue;
        break;
      case 'sn':
        estadoColor = Colors.grey;
        break;
      default:
        estadoColor = Colors.black;
    }

    // Determinar el color del card basado en docEntry
    Color cardColor;
    if (item.docEntry == -1 || item.docEntry == 0) {
      cardColor = Colors.red[50]!; // Color claro rojo para destacar
    } else {
      cardColor = Colors.white; // Color blanco por defecto
    }

    // Función para determinar el color y el icono según diferenciaMinutos
    Map<String, dynamic> getDiferenciaStyle(int diferencia) {
      if (diferencia <= 30) {
        return {
          'color': Colors.green,
          'icon': Icons.check_circle,
          'text': '$diferencia min',
        };
      } else if (diferencia <= 60) {
        return {
          'color': Colors.orange,
          'icon': Icons.warning,
          'text': '$diferencia min',
        };
      } else {
        return {
          'color': Colors.red,
          'icon': Icons.error,
          'text': '$diferencia min',
        };
      }
    }

    // Obtener el estilo para diferenciaMinutos
    Map<String, dynamic>? diferenciaStyle;
    if (item.diferenciaMinutos != null) {
      diferenciaStyle = getDiferenciaStyle(item.diferenciaMinutos!);
    }

    return Card(
      color: cardColor, // Aplicar el color determinado
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 0.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado: Sistema y Factura
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sistema: ${item.db}, N°Factura: ${item.factura}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  item.fechaEntrega ?? '',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            // Dirección de Entrega con botón de mapa
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.blue, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.direccionEntrega ?? 'Sin dirección',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                if (item.latitud != null && item.longitud != null) ...[
                  IconButton(
                    icon: const Icon(Icons.map, color: Colors.blue),
                    onPressed: () {
                      abrirGoogleMaps(context, item.latitud!.toDouble(), item.longitud!.toDouble());
                    },
                    tooltip: 'Ver en Google Maps',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8.0),
            // Cliente y Peso
            Row(
              children: [
                const Icon(Icons.person, color: Colors.blue, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Cliente: ${item.cardName}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const Icon(Icons.scale, color: Colors.blue, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${item.peso?.toStringAsFixed(2)} kg',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            // Chofer y Coche
            Row(
              children: [
                const Icon(Icons.drive_eta, color: Colors.blue, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Chofer: ${item.nombreCompleto}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                if (item.cochePlaca != null && item.cochePlaca!.isNotEmpty) ...[
                  const SizedBox(width: 8.0),
                  const Icon(Icons.directions_car, color: Colors.blue, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Coche: ${item.cochePlaca}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12.0),
            // Observaciones, Diferencia en Minutos y Acción
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Observaciones con Chip Envuelto en Flexible y Tooltip
                Flexible(
                  child: Tooltip(
                    message: 'Observaciones: ${item.obs}',
                    child: Chip(
                      label: Text(
                        'Observaciones: ${item.obs}',
                        style: const TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      backgroundColor: estadoColor,
                    ),
                  ),
                ),
                // Diferencia en Minutos Resaltada
                if (item.diferenciaMinutos != null && diferenciaStyle != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: diferenciaStyle['color'],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          diferenciaStyle['icon'],
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          diferenciaStyle['text'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // Icono de Acción
                IconButton(
                  icon: const Icon(Icons.visibility_outlined, color: Colors.blue),
                  onPressed: () {
                    _showDeliveryDetails(context, item);
                  },
                  tooltip: 'Ver Detalles',
                ),
              ],
            ),
          ],
        ),
      ));
    }

    // Método para mostrar detalles de la entrega en un diálogo
    void _showDeliveryDetails(BuildContext context, DeliveryDriver item) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Detalles de la Entrega ${item.idEntrega}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Factura: ${item.factura}'),
                Text('Cliente: ${item.cardName}'),
                Text('Dirección: ${item.direccionEntrega}'),
                Text('Chofer: ${item.nombreCompleto}'),
                Text('Coche: ${item.cochePlaca ?? 'N/A'}'),
                Text('Peso: ${item.peso?.toStringAsFixed(2)} kg'),
                Text('Observaciones: ${item.obs}'),
                Text('Fecha de Entrega: ${item.fechaEntrega}'),
                Text('Diferencia: ${item.diferenciaMinutos} minutos'),
                // Agrega más detalles según sea necesario
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    }
}

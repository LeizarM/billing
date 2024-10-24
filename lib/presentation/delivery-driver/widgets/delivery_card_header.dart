// File: lib/presentation/delivery-driver/widgets/delivery_card_header.dart
import 'package:billing/domain/delivery-driver/groupedDelivery.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DeliveryCardHeader extends StatefulWidget {
  final GroupedDelivery delivery;
  final Function(String) onObservationChanged; // Callback para manejar cambios

  const DeliveryCardHeader({
    super.key,
    required this.delivery,
    required this.onObservationChanged, // Requerir el callback
  });

  @override
  _DeliveryCardHeaderState createState() => _DeliveryCardHeaderState();
}

class _DeliveryCardHeaderState extends State<DeliveryCardHeader> {
  late TextEditingController _observationController;

  @override
  void initState() {
    super.initState();
    _observationController =
        TextEditingController(text: widget.delivery.obs);
  }

  @override
  void dispose() {
    _observationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDelivered = widget.delivery.isDelivered;
    final primaryColor = Theme.of(context).primaryColor;
    const deliveredColor = Colors.green;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con Avatar e Información Principal
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                backgroundColor:
                    isDelivered ? deliveredColor : primaryColor,
                radius: 25,
                child: Icon(
                  isDelivered ? Icons.check : Icons.local_shipping,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Información Principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.delivery.cardName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tipo: ${widget.delivery.tipo}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Fecha: ${DateFormat('dd/MM/yyyy').format(widget.delivery.docDate)}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Detalles de Entrega
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dirección:',
                style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              SelectableText(
                widget.delivery.addressEntregaMat,
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Total de productos: ${widget.delivery.items.length}',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              // Campo de Observaciones
              TextField(
                controller: _observationController,
                decoration: InputDecoration(
                  labelText: 'Observaciones',
                  labelStyle: TextStyle(color: primaryColor),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 16),
                ),
                maxLines: 3,
                onChanged: (value) {
                  widget.onObservationChanged(value); // Notificar al padre
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

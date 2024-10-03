// File: lib/presentation/delivery-driver/widgets/delivery_card_header.dart
import 'package:billing/domain/delivery-driver/groupedDelivery.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DeliveryCardHeader extends StatefulWidget {
  final GroupedDelivery delivery;
  final Function(String) onObservationChanged; // Callback para manejar cambios

  const DeliveryCardHeader({
    Key? key,
    required this.delivery,
    required this.onObservationChanged, // Requerir el callback
  }) : super(key: key);

  @override
  _DeliveryCardHeaderState createState() => _DeliveryCardHeaderState();
}

class _DeliveryCardHeaderState extends State<DeliveryCardHeader> {
  late TextEditingController _observationController;

  @override
  void initState() {
    super.initState();
    _observationController =
        TextEditingController(text: widget.delivery.obs ?? '');
  }

  @override
  void dispose() {
    _observationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: CircleAvatar(
        backgroundColor: widget.delivery.isDelivered
            ? Colors.green
            : Theme.of(context).primaryColor,
        radius: 25,
        child: Icon(
          widget.delivery.isDelivered ? Icons.check : Icons.local_shipping,
          color: Colors.white,
        ),
      ),
      title: Text(
        widget.delivery.cardName,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'Fecha: ${DateFormat('dd/MM/yyyy').format(widget.delivery.docDate)}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            'Dirección: ${widget.delivery.addressEntregaMat}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            'Total de productos: ${widget.delivery.items.length}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _observationController,
            decoration: InputDecoration(
              labelText: 'Observaciones',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            maxLines: 3,
            onChanged: (value) {
              widget.onObservationChanged(value); // Notificar al padre
            },
          ),
        ],
      ),
    );
  }
}

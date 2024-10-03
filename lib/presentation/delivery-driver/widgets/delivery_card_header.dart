// File: lib/presentation/delivery-driver/widgets/delivery_card_header.dart
import 'package:billing/domain/delivery-driver/groupedDelivery.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DeliveryCardHeader extends StatelessWidget {
  final GroupedDelivery delivery;

  const DeliveryCardHeader({Key? key, required this.delivery})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: CircleAvatar(
        backgroundColor: delivery.isDelivered
            ? Colors.green
            : Theme.of(context).primaryColor,
        radius: 25,
        child: Icon(
          delivery.isDelivered ? Icons.check : Icons.local_shipping,
          color: Colors.white,
        ),
      ),
      title: Text(
        delivery.cardName,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'Fecha: ${DateFormat('dd/MM/yyyy').format(delivery.docDate)}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            'Dirección: ${delivery.addressEntregaMat}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            'Total de productos: ${delivery.items.length}',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

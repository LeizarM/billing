// File: lib/presentation/delivery-driver/widgets/delivery_card.dart
import 'package:billing/domain/delivery-driver/groupedDelivery.dart';
import 'package:billing/presentation/delivery-driver/widgets/delivery_products_expansion_tile.dart';
import 'package:flutter/material.dart';

import 'delivery_card_header.dart';

class DeliveryCard extends StatelessWidget {
  final GroupedDelivery delivery;
  final Function(GroupedDelivery) onMarkAsDelivered;
  final Function(String) onObservationChanged; // Nuevo callback

  const DeliveryCard({
    Key? key,
    required this.delivery,
    required this.onMarkAsDelivered,
    required this.onObservationChanged, // Requerir el callback
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          DeliveryCardHeader(
            delivery: delivery,
            onObservationChanged: (value) {
              onObservationChanged(value);
            },
          ),
          DeliveryProductsExpansionTile(items: delivery.items),
          // Aquí podrías agregar más detalles o acciones relacionadas con la entrega
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => onMarkAsDelivered(delivery),
              child: const Text('Marcar como Entregada'),
            ),
          ),
        ],
      ),
    );
  }
}

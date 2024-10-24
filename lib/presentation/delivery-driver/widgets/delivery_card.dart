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
    super.key,
    required this.delivery,
    required this.onMarkAsDelivered,
    required this.onObservationChanged, // Requerir el callback
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          DeliveryCardHeader(
            delivery: delivery,
            onObservationChanged: onObservationChanged,
          ),
          const Divider(height: 1),
          DeliveryProductsExpansionTile(items: delivery.items),
          // Acciones relacionadas con la entrega
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () => onMarkAsDelivered(delivery),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Marcar como Entregada'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                //backgroundColor: Theme.of(context).primaryColor,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:billing/domain/delivery-driver/groupedDelivery.dart';
import 'package:billing/presentation/delivery-driver/widgets/delivery_action_button.dart';
import 'package:billing/presentation/delivery-driver/widgets/delivery_card_header.dart';
import 'package:billing/presentation/delivery-driver/widgets/delivery_products_expansion_tile.dart';
import 'package:flutter/material.dart';

class DeliveryCard extends StatelessWidget {
  final GroupedDelivery delivery;
  final Function(GroupedDelivery) onMarkAsDelivered;

  const DeliveryCard({
    Key? key,
    required this.delivery,
    required this.onMarkAsDelivered,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          DeliveryCardHeader(delivery: delivery),
          DeliveryProductsExpansionTile(items: delivery.items),
          if (!delivery.isDelivered)
            DeliveryActionButton(
              onPressed: () => onMarkAsDelivered(delivery),
            ),
        ],
      ),
    );
  }
}

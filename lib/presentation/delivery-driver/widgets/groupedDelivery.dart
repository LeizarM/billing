// lib/presentation/widgets/grouped_delivery_card.dart
import 'package:billing/domain/delivery-driver/groupedDelivery.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GroupedDeliveryCard extends StatelessWidget {
  final GroupedDelivery groupedDelivery;
  final Color primaryColor;
  final Color secondaryColor;
  final Color tertiaryColor;
  final VoidCallback onMarkAsDelivered;

  // ignore: use_super_parameters
  const GroupedDeliveryCard({
    Key? key,
    required this.groupedDelivery,
    required this.primaryColor,
    required this.secondaryColor,
    required this.tertiaryColor,
    required this.onMarkAsDelivered,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          groupedDelivery.cardName,
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Fecha: ${DateFormat('dd/MM/yyyy').format(groupedDelivery.docDate)}'),
            Text('Total Productos: ${groupedDelivery.totalQuantity}'),
          ],
        ),
        leading: CircleAvatar(
          backgroundColor:
              groupedDelivery.isDelivered ? secondaryColor : primaryColor,
          child: Icon(
            groupedDelivery.isDelivered ? Icons.check : Icons.local_shipping,
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
                      fontWeight: FontWeight.bold, color: primaryColor),
                ),
                Text(groupedDelivery.addressEntregaMat),
                const SizedBox(height: 8),
                Text(
                  'Productos:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: primaryColor),
                ),
                ...groupedDelivery.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(item.dscription!)),
                          Text(
                            'Cantidad: ${item.quantity}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )),
                if (!groupedDelivery.isDelivered)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('Marcar como entregado'),
                      onPressed: onMarkAsDelivered,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
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
  }
}

import 'package:billing/domain/delivery-driver/deliverDriver.dart';
import 'package:billing/presentation/delivery-driver/widgets/product_item.dart';
import 'package:flutter/material.dart';

class DeliveryProductsExpansionTile extends StatelessWidget {
  final List<DeliveryDriver> items;

  const DeliveryProductsExpansionTile({Key? key, required this.items})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text('Detalles de productos',
          style: TextStyle(fontWeight: FontWeight.w500)),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((item) => ProductItem(item: item)).toList(),
          ),
        ),
      ],
    );
  }
}

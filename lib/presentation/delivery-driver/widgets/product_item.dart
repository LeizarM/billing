// File: lib/presentation/delivery-driver/widgets/product_item.dart
import 'package:billing/domain/delivery-driver/deliverDriver.dart';
import 'package:flutter/material.dart';

class ProductItem extends StatelessWidget {
  final DeliveryDriver item;

  const ProductItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child:
                  Text(item.dscription!, style: const TextStyle(fontSize: 14))),
          Text('Cantidad: ${item.quantity}',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}

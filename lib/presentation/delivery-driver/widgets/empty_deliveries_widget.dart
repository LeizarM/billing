import 'package:flutter/material.dart';

class EmptyDeliveriesWidget extends StatelessWidget {
  const EmptyDeliveriesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No hay entregas pendientes',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

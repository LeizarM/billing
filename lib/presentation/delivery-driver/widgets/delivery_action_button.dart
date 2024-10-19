// File: lib/presentation/delivery-driver/widgets/delivery_action_button.dart
import 'package:flutter/material.dart';

class DeliveryActionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const DeliveryActionButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.check, color: Colors.white),
        label: const Text('Marcar como entregado',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
    );
  }
}

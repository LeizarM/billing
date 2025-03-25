

import 'package:flutter/material.dart';

class ViewDepositosScreen extends StatefulWidget {
  const ViewDepositosScreen({super.key});

  @override
  State<ViewDepositosScreen> createState() => _ViewDepositosScreenState();
}

class _ViewDepositosScreenState extends State<ViewDepositosScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ver Depósitos'),
      ),
      body: const Center(
        child: Text('Pantalla para ver depósitos'),
      ),
    );
  }
}
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DriverViewCarScreen extends StatefulWidget {
  const DriverViewCarScreen({super.key});

  @override
  State<DriverViewCarScreen> createState() => _DriverViewCarScreenState();
}

class _DriverViewCarScreenState extends State<DriverViewCarScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: const Text('DriverViewCarScreen'),
    );
  }
}
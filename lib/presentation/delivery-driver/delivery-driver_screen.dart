import 'package:billing/application/auth/local_storage_service.dart';
import 'package:billing/application/delivery-driver/delivery-driver_service.dart';
import 'package:billing/domain/delivery-driver/deliverDriver.dart';
import 'package:flutter/material.dart';

class DeliveryDriverScreen extends StatefulWidget {
  const DeliveryDriverScreen({super.key});

  @override
  State<DeliveryDriverScreen> createState() => _DeliveryDriverScreenState();
}

class _DeliveryDriverScreenState extends State<DeliveryDriverScreen> {
  final LocalStorageService _localStorageService = LocalStorageService();
  final DeliveryDriverService _deliveryDriverService = DeliveryDriverService();
  List<DeliveryDriver>? _menuItems;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadDelivery();
  }

  Future<void> _loadDelivery() async {
    final userData = await _localStorageService.getUser();
    if (userData != null) {
      final menuItems = await _deliveryDriverService.obtainDelivery(13);
      setState(() {
        _menuItems = menuItems;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Driver'),
      ),
      body: const Center(
        child: Text('Delivery Driver Screen'),
      ),
    );
  }
}

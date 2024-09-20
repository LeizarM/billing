import 'package:billing/infrastructure/persistence/database_helper.dart';
import 'package:billing/presentation/auth/change_password_screen.dart';
import 'package:billing/presentation/dashboard/dashboard_screen.dart';
import 'package:billing/presentation/delivery-driver/delivery-driver_screen.dart';
import 'package:billing/presentation/family/family_list_screen.dart';
import 'package:billing/presentation/item/item_list_screen.dart';
import 'package:billing/presentation/item_detail_storage/item_detail_storage.dart';
import 'package:flutter/material.dart';

import 'presentation/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await DatabaseHelper.instance.database;
  } catch (e) {
    print('Error initializing database: $e');
    // Manejar el error apropiadamente, quizás mostrando un diálogo al usuario
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IPX - ESP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(
              initialIndex: 1,
            ),
        '/change-password': (context) => const ChangePasswordScreen(),
        '/item-detail-storage': (context) => const ItemDetailStorgate(),
        'tprAutorizacion/Autorizacion': (context) => const FamiliesScreen(),
        'trch_choferEntrega/Revision': (context) =>
            const DeliveryDriverScreen(),
        'tven_ventas/VentasView': (context) => const ItemsScreen()
      },
    );
  }
}

import 'package:billing/infrastructure/persistence/database_helper.dart';
import 'package:billing/presentation/auth/change_password_screen.dart';
import 'package:billing/presentation/auth/login_screen.dart';
import 'package:billing/presentation/dashboard/dashboard_screen.dart';
import 'package:billing/presentation/delivery-driver/delivery-driver_screen.dart';
import 'package:billing/presentation/delivery-driver/delivery_driver_start_screen.dart';
import 'package:billing/presentation/item/item_list_screen.dart';
import 'package:billing/presentation/item_detail_storage/item_detail_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await DatabaseHelper.instance.database;
  } catch (e) {
    print('Error initializing database: $e');
    // Manejar el error apropiadamente, quizás mostrando un diálogo al usuario
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool deliveriesActive = prefs.getBool('deliveriesActive') ?? false;

  runApp(MyApp(deliveriesActive: deliveriesActive));
}

class MyApp extends StatelessWidget {
  final bool deliveriesActive;

  // **Importante:** Elimina 'const' del constructor
  MyApp({Key? key, required this.deliveriesActive}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IPX - ESP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Establece la ruta inicial basada en el estado de las entregas
      //initialRoute: deliveriesActive ? '/delivery-driver' : '/login',
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(
              initialIndex: 1,
            ),
        '/change-password': (context) => const ChangePasswordScreen(),
        '/item-detail-storage': (context) => const ItemDetailStorgate(),
        'trch_choferEntrega/Revision': (context) =>
            const DeliveryDriverStartScreen(),
        'tven_ventas/VentasView': (context) => const ItemsScreen(),
        '/delivery-driver': (context) => const DeliveryDriverScreen(),
      },
    );
  }
}

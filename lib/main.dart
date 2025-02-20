import 'package:billing/infrastructure/persistence/database_helper.dart';
import 'package:billing/presentation/auth/change_password_screen.dart';
import 'package:billing/presentation/auth/login_screen.dart';
import 'package:billing/presentation/dashboard/dashboard_screen.dart';
import 'package:billing/presentation/delivery-driver/delivery-driver_screen.dart';
import 'package:billing/presentation/delivery-driver/delivery_driver_start_screen.dart';
import 'package:billing/presentation/delivery-driver/delivery_summary.dart';
import 'package:billing/presentation/driver-car/driver-car_screen.dart';
import 'package:billing/presentation/driver-car/driver-view-car-screen.dart';
import 'package:billing/presentation/item/item_list_screen.dart';
import 'package:billing/presentation/item_detail_storage/item_detail_storage.dart';
import 'package:billing/presentation/register-depositos/register-depositos_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

// Clase para ignorar certificados SSL
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar para aceptar cualquier certificado SSL
  HttpOverrides.global = MyHttpOverrides();
  
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
  const MyApp({super.key, required this.deliveriesActive});

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
        '/delivery-driver': (context) => const DeliveryDriverScreen(deliveries: [],),
        'trch_choferEntrega/Resumen': (context) => const DeliverySummary(),
        'tpre_Solicitud/Solicitud': (context) => const SolicitudChoferScreen(),
        'tpre_Solicitud/VerSolicitud': (context) => const DriverViewCarScreen(),
        'tdep_Deposito/Registro':(context) => RegistrarDepositoPage(),
      },
    );
  }
}
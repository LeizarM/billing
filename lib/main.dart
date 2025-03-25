import 'dart:io';
import 'package:billing/infrastructure/register-depositos/file_picker_helper.dart';
import 'package:billing/presentation/register-depositos/view-depositos_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
import 'package:billing/application/auth/local_storage_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Clave del navegador global para poder navegar desde cualquier parte
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Clase para ignorar certificados SSL
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

// Función simple para verificar token y redireccionar
void checkTokenExpiration() async {
  final localStorageService = LocalStorageService();
  final token = await localStorageService.getToken();
  
  // Si no hay token o está expirado, redirigir al login
  if (token == null || JwtDecoder.isExpired(token)) {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login',
      (Route<dynamic> route) => false,
    );
  }
}

Future<void> main() async {
  // Es indispensable inicializar los bindings de Flutter.
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {  
    try {  
      await FilePickerHelper.getInstance();  
    } catch (e) {  
      print('Error initializing FilePickerHelper: $e');  
    }  
  }

  // Configuramos para aceptar cualquier certificado SSL.
  HttpOverrides.global = MyHttpOverrides();

  // Inicializamos la base de datos y capturamos posibles errores.
  try {
    await DatabaseHelper.instance.database;
  } catch (e) {
    print('Error initializing database: $e');
  }

  // Obtenemos preferencias compartidas para decidir la ruta inicial.
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool deliveriesActive = prefs.getBool('deliveriesActive') ?? false;

  runApp(MyApp(deliveriesActive: deliveriesActive));
}

class MyApp extends StatelessWidget {
  final bool deliveriesActive;
  
  const MyApp({Key? key, required this.deliveriesActive}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IPX - ESP',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, // Clave global para navegación
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(initialIndex: 1),
        '/change-password': (context) => const ChangePasswordScreen(),
        '/item-detail-storage': (context) => const ItemDetailStorgate(),
        'trch_choferEntrega/Revision': (context) => const DeliveryDriverStartScreen(),
        'tven_ventas/VentasView': (context) => const ItemsScreen(),
        '/delivery-driver': (context) => const DeliveryDriverScreen(deliveries: []),
        'trch_choferEntrega/Resumen': (context) => const DeliverySummary(),
        'tpre_Solicitud/Solicitud': (context) => const SolicitudChoferScreen(),
        'tpre_Solicitud/VerSolicitud': (context) => const DriverViewCarScreen(),
        'tdep_Deposito/Registro': (context) => const  RegistrarDepositoPage(),
        'tdep_Deposito/View': (context) => const  ViewDepositosScreen(),
      },
    );
  }
}

// Clase base para extender en tus pantallas donde quieres verificar el token
abstract class TokenAwareState<T extends StatefulWidget> extends State<T> {
  @override
  void initState() {
    super.initState();
    checkTokenExpiration();
  }
}
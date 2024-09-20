import 'package:billing/application/auth/local_storage_service.dart';
import 'package:billing/application/view-menu/view-menu_service.dart';
import 'package:billing/domain/auth/login.dart';
import 'package:billing/domain/view-menu/view-menu.dart';
import 'package:billing/presentation/item/item_list_screen.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required int initialIndex});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0; // Cambiado a 0 para iniciar en el Dashboard
  Login? _userData;
  List<Vista>? _menuItems;
  final LocalStorageService _localStorageService = LocalStorageService();
  final ViewMenuService _viewMenuService = ViewMenuService();
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _widgetOptions = <Widget>[
      DashboardContent(userData: _userData),
      const ItemsScreen(),
    ];
  }

  Future<void> _loadUserData() async {
    final userData = await _localStorageService.getUser();
    if (userData != null) {
      final menuItems =
          await _viewMenuService.obtainViewMenu(userData.codUsuario);
      setState(() {
        _userData = userData;
        _menuItems = menuItems;
        _widgetOptions[0] = DashboardContent(userData: _userData);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Dashboard' : 'Lista de Artículos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Implementar lógica de logout
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(_userData?.nombreCompleto ?? ""),
            accountEmail: Text(_userData?.login ?? ""),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                _userData?.nombreCompleto.substring(0, 1).toUpperCase() ?? "",
                style: const TextStyle(fontSize: 40.0),
              ),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              setState(() {
                _selectedIndex = 0;
              });
              Navigator.of(context).pop();
            },
          ),
          /* ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Lista de Artículos'),
            onTap: () {
              setState(() {
                _selectedIndex = 1;
              });
              Navigator.of(context).pop();
            },
          ), */
          const Divider(),
          if (_menuItems != null) ..._buildMenuItems(_menuItems!),
        ],
      ),
    );
  }

  List<Widget> _buildMenuItems(List<Vista> items) {
    return items.map((item) => _buildMenuItem(item)).toList();
  }

  Widget _buildMenuItem(Vista item) {
    if (item.items != null && item.items!.isNotEmpty) {
      return ExpansionTile(
        title: Text(item.titulo ?? item.label ?? ''),
        children: item.items!.map((child) => _buildMenuItem(child)).toList(),
      );
    } else {
      return ListTile(
        title: Text(item.titulo ?? item.label ?? ''),
        onTap: () {
          _navigateOrShowDialog(context, item);
        },
      );
    }
  }
}

void _navigateOrShowDialog(BuildContext context, Vista item) {
  try {
    Navigator.of(context).pushNamed('${item.routerLink}');
  } catch (e) {
    print('Error al navegar: $e');
    _showRouteNotAvailableDialog(
        context, item.titulo ?? item.label ?? 'Esta vista');
  }
}

void _showRouteNotAvailableDialog(BuildContext context, String viewName) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Vista no disponible'),
        content: Text('$viewName aún no está disponible en la aplicación.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Aceptar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

class DashboardContent extends StatelessWidget {
  final Login? userData;

  const DashboardContent({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenido,',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          Text(
            userData!.nombreCompleto,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.blue[600],
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoCard('Información de Usuario', [
            _buildInfoRow('Cargo', userData!.cargo),
          ]),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }
}

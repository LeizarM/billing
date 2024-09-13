import 'package:billing/application/auth/local_storage_service.dart';
import 'package:billing/domain/auth/login.dart';
import 'package:flutter/material.dart';

import '../item/item_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key, required int initialIndex})
      : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 1;
  Login? _userData;
  final LocalStorageService _localStorageService = LocalStorageService();
  late List<Widget> _widgetOptions;
  bool _isDrawerExpanded = true;

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
    setState(() {
      _userData = userData;
      _widgetOptions[0] = DashboardContent(userData: _userData);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.of(context).pop(); // Cierra el drawer después de seleccionar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IPX - ESP , ${_userData?.login ?? ""}'),
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
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(_userData?.nombreCompleto ?? ""),
            accountEmail: Text(_userData?.login ?? ""),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                _userData?.nombreCompleto.substring(0, 1).toUpperCase() ?? "",
                style: TextStyle(fontSize: 40.0),
              ),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            selected: _selectedIndex == 0,
            onTap: () => _onItemTapped(0),
          ),
          ListTile(
            leading: Icon(Icons.list),
            title: Text('Items'),
            selected: _selectedIndex == 1,
            onTap: () => _onItemTapped(1),
          ),
          Expanded(child: Container()), // Spacer
          ListTile(
            leading: Icon(
                _isDrawerExpanded ? Icons.chevron_left : Icons.chevron_right),
            title: Text(_isDrawerExpanded ? 'Colapsar' : 'Expandir'),
            onTap: () {
              setState(() {
                _isDrawerExpanded = !_isDrawerExpanded;
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class DashboardContent extends StatelessWidget {
  final Login? userData;

  const DashboardContent({Key? key, this.userData}) : super(key: key);

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

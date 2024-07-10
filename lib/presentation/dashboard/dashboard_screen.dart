import 'package:billing/application/auth/local_storage_service.dart';
import 'package:billing/domain/auth/login.dart';
import 'package:flutter/material.dart';

import '../item/item_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required int initialIndex});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 1;
  Login? _userData;
  final LocalStorageService _localStorageService = LocalStorageService();
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _widgetOptions = <Widget>[
      DashboardContent(userData: _userData),
      ItemsScreen(),
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
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Items',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
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
            /*  _buildInfoRow('Tipo de Usuario', userData!.tipoUsuario),
            _buildInfoRow('Código de Usuario', userData!.codUsuario.toString()),
            _buildInfoRow(
                'Código de Empleado', userData!.codEmpleado.toString()), */
          ]),
          /*  const SizedBox(height: 16),
          _buildInfoCard('Información de Empresa', [
            _buildInfoRow('Código de Empresa', userData!.codEmpresa.toString()),
            _buildInfoRow('Código de Ciudad', userData!.codCiudad.toString()),
          ]), */
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

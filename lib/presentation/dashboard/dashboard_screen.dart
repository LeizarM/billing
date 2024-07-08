import 'package:billing/application/auth/local_storage_service.dart';
import 'package:billing/domain/auth/login.dart';
import 'package:flutter/material.dart';

import '../item/item_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  Login? _userData;
  final LocalStorageService _localStorageService = LocalStorageService();

  final List<Widget> _widgetOptions = <Widget>[
    DashboardContent(),
    //FamiliesScreen(),
    ItemsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await _localStorageService.getUser();
    setState(() {
      _userData = userData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bosque , ${_userData?.login}'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
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
          /* BottomNavigationBarItem(
            icon: Icon(Icons.family_restroom),
            label: 'Families',
          ), */
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
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Contenido del Dashboard'),
    );
  }
}

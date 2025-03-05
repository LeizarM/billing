import 'package:billing/application/auth/local_storage_service.dart';
import 'package:billing/application/view-menu/view-menu_service.dart';
import 'package:billing/domain/auth/login.dart';
import 'package:billing/domain/view-menu/view-menu.dart';
import 'package:billing/presentation/item/item_list_screen.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.initialIndex});

  final int initialIndex;

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  Login? _userData;
  List<Vista>? _menuItems;
  final LocalStorageService _localStorageService = LocalStorageService();
  final ViewMenuService _viewMenuService = ViewMenuService();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _localStorageService.getUser();
      if (userData != null) {
        final menuItems =
            await _viewMenuService.obtainViewMenu(userData.codUsuario);
        if (mounted) {
          setState(() {
            _userData = userData;
            _menuItems = _cleanMenuItems(menuItems);
            _isLoading = false;
          });
        }
      } else {
        _setErrorState('No se pudo cargar la información del usuario.');
      }
    } catch (e) {
      _setErrorState('Error al cargar los datos: $e');
    }
  }

  void _setErrorState(String message) {
    if (mounted) {
      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
    }
  }

  List<Vista> _cleanMenuItems(List<Vista> items) {
    return items.where((item) {
      if (item.items != null && item.items!.isNotEmpty) {
        item.items = _cleanMenuItems(item.items!);
        return item.items!.isNotEmpty;
      }
      return _isValidRoute(item.routerLink);
    }).toList();
  }

  bool _isValidRoute(String? routerLink) {
    if (routerLink == null || routerLink.isEmpty) {
      return false;
    }
    bool isValid = _checkRouteExists(routerLink);
    print('Checking route: $routerLink, isValid: $isValid');
    return isValid;
  }

  bool _checkRouteExists(String routeName) {
    final RouteFactory? generator =
        Navigator.of(context).widget.onGenerateRoute;
    if (generator == null) {
      print('Route generator is null');
      return false;
    }
    final Route<dynamic>? route = generator(RouteSettings(name: routeName));
    return route != null;
  }

  @override
  Widget build(BuildContext context) {
    // Definimos una paleta de colores moderna utilizando ColorScheme
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0 ? 'Dashboard' : 'Lista de Artículos',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
        elevation: 4,
        backgroundColor: colorScheme.primary,
      ),
      drawer: _buildDrawer(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
        ),
      );
    }
    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(
            color: Colors.redAccent,
            fontSize: 16,
          ),
        ),
      );
    }
    if (_selectedIndex == 0) {
      return _buildDashboardContent();
    } else {
      return const ItemsScreen();
    }
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          const SizedBox(height: 32),
          _buildInfoCard('Información de Usuario', [
            _buildInfoRow('Cargo', _userData!.cargo),
          ]),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blueAccent.withOpacity(0.1),
            Colors.blueAccent.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.blueAccent,
            child: Text(
              _userData!.nombreCompleto.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Bienvenido(a),',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.blueAccent,
            ),
          ),
          Text(
            _userData!.nombreCompleto,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.grey.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.blueAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: <Widget>[
          _buildDrawerHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                _buildDrawerItem(Icons.dashboard, 'Dashboard', 0),
                const Divider(thickness: 1),
                if (_menuItems != null) ..._buildMenuItems(_menuItems!),
              ],
            ),
          ),
          _buildDrawerFooter(),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return UserAccountsDrawerHeader(
      decoration: const BoxDecoration(
        color: Colors.blueAccent,
        image: DecorationImage(
          image: AssetImage('assets/drawer_header_bg.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        child: Text(
          _userData?.nombreCompleto.substring(0, 1).toUpperCase() ?? "U",
          style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent),
        ),
      ),
      accountName: Text(
        _userData?.nombreCompleto ?? "",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      accountEmail: Text(
        _userData?.login ?? "",
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildDrawerFooter() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        '© 2024 Impexpap - Esppapel.',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(
        icon,
        color: _selectedIndex == index ? Colors.blueAccent : Colors.grey[700],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: _selectedIndex == index ? Colors.blueAccent : Colors.grey[800],
          fontWeight:
              _selectedIndex == index ? FontWeight.bold : FontWeight.normal,
          fontSize: 16,
        ),
      ),
      trailing: _selectedIndex == index
          ? const Icon(Icons.check, color: Colors.blueAccent)
          : null,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.of(context).pop();
      },
    );
  }

  List<Widget> _buildMenuItems(List<Vista> items) {
    return items.map((item) => _buildMenuItem(item)).toList();
  }

  Widget _buildMenuItem(Vista item, {double indentation = 0}) {
    if (item.items != null && item.items!.isNotEmpty) {
      return Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: const Icon(Icons.folder, color: Colors.blueAccent),
          title: Text(
            item.titulo ?? item.label ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          children: item.items!
              .map((child) =>
                  _buildMenuItem(child, indentation: indentation + 16))
              .toList(),
        ),
      );
    } else {
      return ListTile(
        contentPadding: EdgeInsets.only(left: 24.0 + indentation, right: 16.0),
        leading: const Icon(
          Icons.circle,
          size: 12,
          color: Colors.blueAccent,
        ),
        title: Text(
          item.titulo ?? item.label ?? '',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[800],
          ),
        ),
        onTap: () {
          if (item.routerLink != null && item.routerLink!.isNotEmpty) {
            print('Navigating to: ${item.routerLink}');
            Navigator.of(context).pushNamed(item.routerLink!);
          }
        },
      );
    }
  }
}
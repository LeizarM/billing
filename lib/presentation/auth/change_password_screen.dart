import 'package:flutter/material.dart';

import '../../application/auth/auth_service.dart';
import 'package:billing/presentation/dashboard/dashboard_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  final bool isForced;

  const ChangePasswordScreen({super.key, this.isForced = false});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _authService.changePassword(_newPasswordController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contraseña cambiada con éxito')),
        );
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const DashboardScreen(initialIndex: 0),
            ),
          );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cambiar la contraseña: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar Contraseña'),
        automaticallyImplyLeading: !widget.isForced,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.isForced)
                const Text(
                  'Por razones de seguridad, debe cambiar su contraseña.',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nueva Contraseña'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una nueva contraseña';
                  }
                  if (value == '123456789') {
                    return 'La nueva contraseña no puede ser la contraseña por defecto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Confirmar Nueva Contraseña'),
                validator: (value) {
                  if (value != _newPasswordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Cambiar Contraseña'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

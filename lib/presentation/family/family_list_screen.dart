import 'package:flutter/material.dart';

class FamiliesScreen extends StatelessWidget {
  const FamiliesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista de ejemplo de familias
    final List<String> families = [
      'Familia Pérez',
      'Familia González',
      'Familia Rodríguez',
      'Familia Fernández',
      'Familia López',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Familias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implementar búsqueda
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: families.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(families[index][0]), // Primera letra del nombre
              ),
              title: Text(families[index]),
              subtitle: Text('Miembros: ${(index + 2)}'), // Número de ejemplo
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () {
                  // Navegar a los detalles de la familia
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Lógica para agregar una nueva familia
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';

Future<bool?> showConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Confirmar entrega',
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: const Text(
          '¿Estás seguro de que quieres marcar esta entrega como completada?'),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        ElevatedButton(
          child: const Text('Confirmar'),
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
      ],
    ),
  );
}

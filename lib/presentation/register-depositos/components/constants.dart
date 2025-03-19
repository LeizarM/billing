
// Input Decoration común para todos los campos
import 'package:flutter/material.dart';

// Estilos globales para componentes de Registrar Depósito
const double kPadding = 16.0;
const double kFieldSpacing = 16.0;
const double kBorderRadius = 12.0;


InputDecoration inputDecoration(String label, {IconData? icon}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: icon != null ? Icon(icon, color: Colors.teal) : null,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kBorderRadius),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kBorderRadius),
      borderSide: const BorderSide(color: Colors.teal, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
  );
}

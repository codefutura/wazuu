import 'package:flutter/material.dart';

/// Convierte un color guardado como `#RRGGBB` (columna `color` de
/// `categorias`) a `Color`.
Color colorFromHex(String hex) {
  final normalizado = hex.replaceFirst('#', '');
  return Color(int.parse('FF$normalizado', radix: 16));
}

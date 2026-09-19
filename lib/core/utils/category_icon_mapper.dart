import 'package:flutter/material.dart';

/// Traduce el string `icono` guardado en `categorias` (sección 8 de
/// CLAUDE.md, ver `seed_categorias.dart`) al ícono real de Material.
abstract final class CategoryIconMapper {
  static const _iconos = {
    'shopping_bag': Icons.shopping_bag,
    'restaurant': Icons.restaurant,
    'account_balance': Icons.account_balance,
    'bolt': Icons.bolt,
    'directions_car': Icons.directions_car,
    'subscriptions': Icons.subscriptions,
    'category': Icons.category,
    'payments': Icons.payments,
    'swap_horiz': Icons.swap_horiz,
    'attach_money': Icons.attach_money,
  };

  static IconData iconFor(String nombre) => _iconos[nombre] ?? Icons.category;
}

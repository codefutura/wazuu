import '../../../categorization/domain/entities/categoria.dart';

/// Gasto del mes actual agrupado por categoría — ver
/// `ResumenMensualCalculator` (sección 9.2 de CLAUDE.md, "total por
/// categoría después de tendencia").
class CategoriaTotal {
  const CategoriaTotal({
    required this.categoria,
    required this.montoDop,
    required this.montoUsd,
  });

  final Categoria categoria;
  final double montoDop;
  final double montoUsd;
}

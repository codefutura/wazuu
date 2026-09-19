import '../../../categorization/domain/entities/categoria.dart';
import 'presupuesto.dart';

/// Cuánto se ha gastado de un presupuesto en el período actual
/// (sección 9.5 de CLAUDE.md).
///
/// `gastadoDop` consolida gastos en USD solo si había tasa de cambio
/// disponible al calcularlo — `usdSinConsolidar` avisa cuando parte del
/// gasto real quedó fuera del cálculo por no haber tasa configurada,
/// en vez de fingir que no existe.
class ProgresoPresupuesto {
  const ProgresoPresupuesto({
    required this.presupuesto,
    required this.categoria,
    required this.gastadoDop,
    required this.usdSinConsolidar,
  });

  final Presupuesto presupuesto;

  /// `null` si es el presupuesto total.
  final Categoria? categoria;
  final double gastadoDop;
  final bool usdSinConsolidar;

  double get porcentaje =>
      presupuesto.montoLimite <= 0 ? 0 : gastadoDop / presupuesto.montoLimite;

  bool get alcanzoAdvertencia => porcentaje >= 0.8;
  bool get alcanzoLimite => porcentaje >= 1.0;
}

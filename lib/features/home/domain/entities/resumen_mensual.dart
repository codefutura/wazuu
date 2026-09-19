import 'categoria_total.dart';

class PuntoTendenciaMensual {
  const PuntoTendenciaMensual({required this.mes, required this.balanceNetoDop});

  final DateTime mes;
  final double balanceNetoDop;
}

/// Resultado del resumen mensual (sección 9.2 de CLAUDE.md).
///
/// `tasaCambioReferencia` puede ser `null` si el usuario todavía no la
/// configuró (Ajustes, sección 9.6, pendiente) — en ese caso no se
/// puede consolidar DOP + USD; `balanceNetoConsolidadoDop` y
/// `tendenciaSeisMeses` lo reflejan en vez de asumir una tasa.
class ResumenMensual {
  const ResumenMensual({
    required this.mes,
    required this.ingresosDop,
    required this.ingresosUsd,
    required this.gastosDop,
    required this.gastosUsd,
    required this.tasaCambioReferencia,
    required this.variacionVsMesAnteriorPorcentaje,
    required this.tendenciaMensual,
    required this.totalTransacciones,
    required this.gastoPorCategoria,
  });

  final DateTime mes;
  final double ingresosDop;
  final double ingresosUsd;
  final double gastosDop;
  final double gastosUsd;
  final double? tasaCambioReferencia;
  final double? variacionVsMesAnteriorPorcentaje;

  /// Uno o más meses, según el rango elegido en la pantalla de inicio
  /// (3/6/12 meses) — el nombre ya no asume "seis meses" fijo.
  final List<PuntoTendenciaMensual> tendenciaMensual;
  final int totalTransacciones;

  /// Gasto del mes actual agrupado por categoría, de mayor a menor
  /// (sección 9.2 de CLAUDE.md) — sin ingreso, por la misma razón que
  /// el resto de la pantalla de inicio: los bancos no lo notifican.
  final List<CategoriaTotal> gastoPorCategoria;

  double? get balanceNetoConsolidadoDop {
    final tasa = tasaCambioReferencia;
    if (tasa == null) return null;
    final ingresos = ingresosDop + ingresosUsd * tasa;
    final gastos = gastosDop + gastosUsd * tasa;
    return ingresos - gastos;
  }

  /// Gasto del mes en DOP, consolidando el gasto en USD si hay tasa
  /// configurada — `null` solo cuando hay gasto en USD sin tasa para
  /// convertirlo. Los bancos solo notifican gastos/retiros, no
  /// depósitos, así que el ingreso no es una cifra confiable para
  /// mostrar como titular (sección 9.2 de CLAUDE.md).
  double? get gastoTotalDop {
    if (gastosUsd == 0) return gastosDop;
    final tasa = tasaCambioReferencia;
    if (tasa == null) return null;
    return gastosDop + gastosUsd * tasa;
  }
}

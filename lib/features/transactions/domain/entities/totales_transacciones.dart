/// Totales de un conjunto de transacciones ya filtrado (sección 9.4 de
/// CLAUDE.md — "quiero ver el total del rango de fecha seleccionado").
class TotalesTransacciones {
  const TotalesTransacciones({
    required this.ingresosDop,
    required this.gastosDop,
    required this.ingresosUsd,
    required this.gastosUsd,
  });

  final double ingresosDop;
  final double gastosDop;
  final double ingresosUsd;
  final double gastosUsd;

  double get balanceDop => ingresosDop - gastosDop;
  double get balanceUsd => ingresosUsd - gastosUsd;

  bool get hayMovimientoUsd => ingresosUsd != 0 || gastosUsd != 0;
}

import 'totales_transacciones.dart';

/// Total de un banco dentro de un conjunto de transacciones ya
/// filtrado — ver `TotalesPorBancoCalculator`.
class TotalBanco {
  const TotalBanco({required this.nombreBanco, required this.totales});

  final String nombreBanco;
  final TotalesTransacciones totales;
}

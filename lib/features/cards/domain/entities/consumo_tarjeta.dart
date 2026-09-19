import 'tarjeta.dart';

/// Consumo del período (mes actual) de una tarjeta, por moneda —
/// carrusel de tarjetas, sección 9.3 de CLAUDE.md.
class ConsumoTarjeta {
  const ConsumoTarjeta({
    required this.tarjeta,
    required this.consumoDop,
    required this.consumoUsd,
  });

  final Tarjeta tarjeta;
  final double consumoDop;
  final double consumoUsd;

  /// `null` si la tarjeta es de débito (sin límite) o no tiene límite
  /// configurado.
  double? get progresoLimite {
    final limite = tarjeta.limiteCredito;
    if (tarjeta.tipo != TipoTarjeta.credito || limite == null || limite <= 0) {
      return null;
    }
    // Aproximación: solo considera el consumo en DOP contra el límite
    // (también en DOP) — mezclar con USD requeriría la tasa de cambio,
    // que esta pantalla no necesariamente tiene disponible.
    return (consumoDop / limite).clamp(0, 1);
  }
}

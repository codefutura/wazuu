/// Tasa de cambio USD/DOP del día, según el Banco Central de la
/// República Dominicana (sección 9.6 de CLAUDE.md).
class TasaBcrd {
  const TasaBcrd({required this.compra, required this.venta, required this.fecha});

  final double compra;
  final double venta;
  final DateTime fecha;
}

/// Cualquier falla al consultar o interpretar la respuesta del Banco
/// Central — el mensaje ya está listo para mostrarle al usuario.
class BcrdExchangeRateException implements Exception {
  const BcrdExchangeRateException(this.message);

  final String message;

  @override
  String toString() => message;
}

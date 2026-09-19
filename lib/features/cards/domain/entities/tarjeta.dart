enum TipoTarjeta { debito, credito }

/// Fila de la tabla `tarjetas` (sección 6 de CLAUDE.md).
class Tarjeta {
  const Tarjeta({
    required this.id,
    required this.apodo,
    required this.ultimos4Digitos,
    required this.tipo,
    required this.bancoId,
    required this.nombreBanco,
    this.limiteCredito,
    this.fechaCorte,
    this.fechaPago,
  });

  final int id;
  final String apodo;
  final String ultimos4Digitos;
  final TipoTarjeta tipo;
  final int bancoId;
  final String nombreBanco;
  final double? limiteCredito;
  final DateTime? fechaCorte;
  final DateTime? fechaPago;
}

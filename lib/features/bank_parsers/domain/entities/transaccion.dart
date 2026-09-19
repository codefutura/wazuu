import '../../../../core/domain/estado_transaccion.dart';
import '../../../../core/domain/moneda.dart';
import '../../../../core/domain/tipo_transaccion.dart';

/// Transacción extraída de un correo bancario (sección 6 de CLAUDE.md).
///
/// No incluye `categoria_id` (motor de categorización, Fase 6),
/// `tarjeta_id`/`banco_id` (los resuelve quien inserte, cruzando contra
/// las tablas locales) ni `hash_dedupe` (se calcula al insertar) — un
/// parser solo interpreta el texto del correo, no toca la base de
/// datos.
class Transaccion {
  const Transaccion({
    required this.monto,
    required this.moneda,
    required this.fecha,
    required this.comercio,
    required this.estado,
    required this.tipoTransaccion,
    required this.emailIdOrigen,
    this.tarjetaUltimos4Digitos,
  });

  final double monto;
  final Moneda moneda;
  final DateTime fecha;
  final String comercio;
  final EstadoTransaccion estado;
  final TipoTransaccion tipoTransaccion;
  final String emailIdOrigen;
  final String? tarjetaUltimos4Digitos;
}

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
    this.categoriaSugerida,
  });

  final double monto;
  final Moneda moneda;
  final DateTime fecha;
  final String comercio;
  final EstadoTransaccion estado;
  final TipoTransaccion tipoTransaccion;
  final String emailIdOrigen;
  final String? tarjetaUltimos4Digitos;

  /// Nombre de categoría que el parser sugiere para este tipo de
  /// transacción cuando el comercio en sí no sirve como pista (ej. una
  /// transferencia donde el "comercio" es el nombre del beneficiario,
  /// que varía en cada correo y nunca va a calzar con una regla de
  /// palabra clave). El motor de categorización la usa solo si ninguna
  /// regla aprendida calza — una recategorización manual del usuario
  /// siempre tiene prioridad.
  final String? categoriaSugerida;
}

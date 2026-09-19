import '../../../../core/domain/estado_transaccion.dart';
import '../../../../core/domain/moneda.dart';
import '../../../../core/domain/tipo_transaccion.dart';
import '../../../categorization/domain/entities/categoria.dart';

/// Una fila real de la tabla `transacciones`, ya resuelta contra
/// `categorias` y `tarjetas` — lista para mostrarse (sección 6 de
/// CLAUDE.md).
///
/// Distinta de `bank_parsers.Transaccion`: esa es la salida cruda de un
/// parser antes de insertarse; esta es lo que ya vive en la base de
/// datos, con `id` y la categoría resuelta.
class TransaccionRegistro {
  const TransaccionRegistro({
    required this.id,
    required this.monto,
    required this.moneda,
    required this.fecha,
    required this.comercio,
    required this.estado,
    required this.tipoTransaccion,
    required this.categoria,
    required this.bancoId,
    required this.nombreBanco,
    this.tarjetaId,
    this.tarjetaApodo,
    this.tarjetaUltimos4Digitos,
  });

  final int id;
  final double monto;
  final Moneda moneda;
  final DateTime fecha;
  final String comercio;
  final EstadoTransaccion estado;
  final TipoTransaccion tipoTransaccion;
  final Categoria categoria;

  /// `transacciones.banco_id` — a diferencia de `tarjetaId`, nunca es
  /// nulo (sección 6 de CLAUDE.md: toda transacción viene de un correo
  /// de un banco conectado, tenga tarjeta resuelta o no).
  final int bancoId;
  final String nombreBanco;
  final int? tarjetaId;
  final String? tarjetaApodo;
  final String? tarjetaUltimos4Digitos;
}

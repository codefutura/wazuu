import '../../../../core/domain/estado_transaccion.dart';
import '../../../../core/domain/moneda.dart';
import '../../../../core/domain/tipo_transaccion.dart';
import '../entities/transaccion_huerfana.dart';
import '../entities/transaccion_registro.dart';

abstract interface class TransaccionesRepository {
  /// Transacciones en `[desde, hasta]` (ambos inclusive, en fecha local),
  /// filtrables opcionalmente por categoría y tarjeta — usado tanto por
  /// la lista de transacciones como por el resumen mensual.
  Future<List<TransaccionRegistro>> obtener({
    DateTime? desde,
    DateTime? hasta,
    int? categoriaId,
    int? tarjetaId,
  });

  /// Recategorizar con un tap (sección 4 de CLAUDE.md — cualquier
  /// categorización automática debe ser editable).
  Future<void> actualizarCategoria({
    required int transaccionId,
    required int categoriaId,
  });

  /// Inserta una transacción parseada de un correo bancario. `hashDedupe`
  /// (monto+fecha+comercio+banco_id, sección 6 de CLAUDE.md) tiene un
  /// índice `UNIQUE` en la base — si ya existe, no se inserta de nuevo.
  /// Devuelve `true` si realmente se insertó (`false` si era un
  /// duplicado ya visto).
  Future<bool> insertar({
    required double monto,
    required Moneda moneda,
    required DateTime fecha,
    required String comercio,
    required EstadoTransaccion estado,
    required TipoTransaccion tipoTransaccion,
    required int categoriaId,
    int? tarjetaId,
    required int bancoId,
    required String emailIdOrigen,
    required String hashDedupe,
    String? tarjetaUltimos4Digitos,
  });

  /// Vincula retroactivamente transacciones que llegaron antes de que
  /// existiera esta tarjeta. Devuelve cuántas se vincularon (para
  /// informarle al usuario tras crear la tarjeta).
  Future<int> reasignarTarjetaHuerfanas({
    required int bancoId,
    required String ultimos4Digitos,
    required int tarjetaId,
  });

  /// Transacciones de `bancoId` sin tarjeta asociada — incluye a las
  /// que se sincronizaron antes de esta versión, cuando todavía no se
  /// guardaba `tarjeta_ultimos_4_digitos` (por eso no las encuentra
  /// `reasignarTarjetaHuerfanas`, que sí depende de esa columna). Solo
  /// trae `id` + `emailIdOrigen` para volver a pedirle el correo
  /// original a Gmail y re-parsearlo.
  Future<List<TransaccionHuerfana>> obtenerHuerfanasPorBanco(int bancoId);

  /// Vincula una transacción puntual encontrada por
  /// `obtenerHuerfanasPorBanco` tras re-parsear su correo original.
  Future<void> vincularTarjeta({
    required int transaccionId,
    required int tarjetaId,
    required String tarjetaUltimos4Digitos,
  });
}

import '../../../core/domain/estado_transaccion.dart';
import '../../../core/domain/moneda.dart';
import '../../../core/domain/tipo_transaccion.dart';
import 'entities/totales_transacciones.dart';
import 'entities/transaccion_registro.dart';

/// Suma ingresos/gastos por moneda para el total de un rango
/// filtrado — pura lógica de dominio, sin tocar la base de datos.
///
/// Solo cuenta transacciones `aprobada`, igual que
/// `ResumenMensualCalculator` — una declinada no movió dinero de
/// verdad.
class TotalesTransaccionesCalculator {
  const TotalesTransaccionesCalculator();

  TotalesTransacciones calcular(List<TransaccionRegistro> transacciones) {
    return TotalesTransacciones(
      ingresosDop: _sumar(transacciones, TipoTransaccion.ingreso, Moneda.dop),
      gastosDop: _sumar(transacciones, TipoTransaccion.gasto, Moneda.dop),
      ingresosUsd: _sumar(transacciones, TipoTransaccion.ingreso, Moneda.usd),
      gastosUsd: _sumar(transacciones, TipoTransaccion.gasto, Moneda.usd),
    );
  }

  double _sumar(
    List<TransaccionRegistro> transacciones,
    TipoTransaccion tipo,
    Moneda moneda,
  ) {
    var total = 0.0;
    for (final t in transacciones) {
      if (t.tipoTransaccion == tipo &&
          t.moneda == moneda &&
          t.estado == EstadoTransaccion.aprobada) {
        total += t.monto;
      }
    }
    return total;
  }
}

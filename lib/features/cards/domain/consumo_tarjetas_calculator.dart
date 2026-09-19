import '../../../core/domain/estado_transaccion.dart';
import '../../../core/domain/moneda.dart';
import '../../../core/domain/tipo_transaccion.dart';
import '../../transactions/domain/entities/transaccion_registro.dart';
import 'entities/consumo_tarjeta.dart';
import 'entities/tarjeta.dart';

/// Calcula el consumo del período (mes) de cada tarjeta — pura lógica
/// de dominio, sin tocar la base de datos.
class ConsumoTarjetasCalculator {
  const ConsumoTarjetasCalculator();

  List<ConsumoTarjeta> calcular({
    required List<Tarjeta> tarjetas,
    required List<TransaccionRegistro> transaccionesDelPeriodo,
  }) {
    return tarjetas.map((tarjeta) {
      final delTarjeta = transaccionesDelPeriodo.where(
        (t) =>
            t.tarjetaId == tarjeta.id &&
            t.tipoTransaccion == TipoTransaccion.gasto &&
            t.estado == EstadoTransaccion.aprobada,
      );
      return ConsumoTarjeta(
        tarjeta: tarjeta,
        consumoDop: _sumar(delTarjeta, Moneda.dop),
        consumoUsd: _sumar(delTarjeta, Moneda.usd),
      );
    }).toList();
  }

  /// Consolidado en DOP de todas las tarjetas. `null` si hay consumo en
  /// USD pero no hay tasa de cambio configurada para consolidarlo.
  double? consolidadoDop(List<ConsumoTarjeta> consumos, double? tasaCambioReferencia) {
    final totalUsd = consumos.fold<double>(0, (acc, c) => acc + c.consumoUsd);
    final totalDop = consumos.fold<double>(0, (acc, c) => acc + c.consumoDop);
    if (totalUsd == 0) return totalDop;
    if (tasaCambioReferencia == null) return null;
    return totalDop + totalUsd * tasaCambioReferencia;
  }

  double _sumar(Iterable<TransaccionRegistro> transacciones, Moneda moneda) {
    var total = 0.0;
    for (final t in transacciones) {
      if (t.moneda == moneda) total += t.monto;
    }
    return total;
  }
}

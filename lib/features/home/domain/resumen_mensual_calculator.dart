import '../../../core/domain/estado_transaccion.dart';
import '../../../core/domain/moneda.dart';
import '../../../core/domain/tipo_transaccion.dart';
import '../../categorization/domain/entities/categoria.dart';
import '../../transactions/domain/entities/transaccion_registro.dart';
import 'entities/categoria_total.dart';
import 'entities/resumen_mensual.dart';

/// Calcula el resumen mensual a partir de transacciones ya cargadas —
/// pura lógica de dominio, sin tocar la base de datos.
class ResumenMensualCalculator {
  const ResumenMensualCalculator();

  /// `transacciones` debe cubrir, como mínimo, `mesesTendencia` meses
  /// antes de `mesObjetivo` hasta el propio `mesObjetivo`, para poder
  /// armar la tendencia y la comparación con el mes anterior.
  ResumenMensual calcular({
    required List<TransaccionRegistro> transacciones,
    required DateTime mesObjetivo,
    double? tasaCambioReferencia,
    int mesesTendencia = 6,
  }) {
    final mesActual = DateTime(mesObjetivo.year, mesObjetivo.month);
    final delMesActual = _delMes(transacciones, mesActual);

    final ingresosDop = _sumar(delMesActual, TipoTransaccion.ingreso, Moneda.dop);
    final ingresosUsd = _sumar(delMesActual, TipoTransaccion.ingreso, Moneda.usd);
    final gastosDop = _sumar(delMesActual, TipoTransaccion.gasto, Moneda.dop);
    final gastosUsd = _sumar(delMesActual, TipoTransaccion.gasto, Moneda.usd);

    double? variacion;
    final tendencia = <PuntoTendenciaMensual>[];

    if (tasaCambioReferencia != null) {
      final balanceActual =
          (ingresosDop + ingresosUsd * tasaCambioReferencia) -
          (gastosDop + gastosUsd * tasaCambioReferencia);

      final mesAnterior = DateTime(mesActual.year, mesActual.month - 1);
      final delMesAnterior = _delMes(transacciones, mesAnterior);
      if (delMesAnterior.isNotEmpty) {
        final balanceAnterior = _balanceNetoDop(
          delMesAnterior,
          tasaCambioReferencia,
        );
        if (balanceAnterior != 0) {
          variacion =
              ((balanceActual - balanceAnterior) / balanceAnterior.abs()) *
              100;
        }
      }

      for (var i = mesesTendencia - 1; i >= 0; i--) {
        final mes = DateTime(mesActual.year, mesActual.month - i);
        tendencia.add(
          PuntoTendenciaMensual(
            mes: mes,
            balanceNetoDop: _balanceNetoDop(
              _delMes(transacciones, mes),
              tasaCambioReferencia,
            ),
          ),
        );
      }
    }

    return ResumenMensual(
      mes: mesActual,
      ingresosDop: ingresosDop,
      ingresosUsd: ingresosUsd,
      gastosDop: gastosDop,
      gastosUsd: gastosUsd,
      tasaCambioReferencia: tasaCambioReferencia,
      variacionVsMesAnteriorPorcentaje: variacion,
      tendenciaMensual: tendencia,
      totalTransacciones: delMesActual.length,
      gastoPorCategoria: _gastoPorCategoria(delMesActual),
    );
  }

  List<CategoriaTotal> _gastoPorCategoria(
    List<TransaccionRegistro> delMesActual,
  ) {
    final porCategoria = <int, ({Categoria categoria, double dop, double usd})>{};
    for (final t in delMesActual) {
      if (t.tipoTransaccion != TipoTransaccion.gasto ||
          t.estado != EstadoTransaccion.aprobada) {
        continue;
      }
      final actual = porCategoria[t.categoria.id];
      porCategoria[t.categoria.id] = (
        categoria: t.categoria,
        dop: (actual?.dop ?? 0) + (t.moneda == Moneda.dop ? t.monto : 0),
        usd: (actual?.usd ?? 0) + (t.moneda == Moneda.usd ? t.monto : 0),
      );
    }

    final resultado = [
      for (final entrada in porCategoria.values)
        CategoriaTotal(
          categoria: entrada.categoria,
          montoDop: entrada.dop,
          montoUsd: entrada.usd,
        ),
    ];
    resultado.sort((a, b) => b.montoDop.compareTo(a.montoDop));
    return resultado;
  }

  List<TransaccionRegistro> _delMes(
    List<TransaccionRegistro> transacciones,
    DateTime mes,
  ) {
    return transacciones
        .where((t) => t.fecha.year == mes.year && t.fecha.month == mes.month)
        .toList();
  }

  double _balanceNetoDop(List<TransaccionRegistro> transacciones, double tasa) {
    final ingresos =
        _sumar(transacciones, TipoTransaccion.ingreso, Moneda.dop) +
        _sumar(transacciones, TipoTransaccion.ingreso, Moneda.usd) * tasa;
    final gastos =
        _sumar(transacciones, TipoTransaccion.gasto, Moneda.dop) +
        _sumar(transacciones, TipoTransaccion.gasto, Moneda.usd) * tasa;
    return ingresos - gastos;
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

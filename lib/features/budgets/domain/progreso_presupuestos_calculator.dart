import '../../../core/domain/estado_transaccion.dart';
import '../../../core/domain/moneda.dart';
import '../../../core/domain/tipo_transaccion.dart';
import '../../categorization/domain/entities/categoria.dart';
import '../../transactions/domain/entities/transaccion_registro.dart';
import 'entities/presupuesto.dart';
import 'entities/progreso_presupuesto.dart';

/// Calcula cuánto se ha gastado de cada presupuesto en el período —
/// pura lógica de dominio, sin tocar la base de datos.
class ProgresoPresupuestosCalculator {
  const ProgresoPresupuestosCalculator();

  List<ProgresoPresupuesto> calcular({
    required List<Presupuesto> presupuestos,
    required List<TransaccionRegistro> transaccionesDelPeriodo,
    required List<Categoria> categorias,
    double? tasaCambioReferencia,
  }) {
    final categoriasPorId = {for (final c in categorias) c.id: c};

    return presupuestos.map((presupuesto) {
      final gastosRelevantes = transaccionesDelPeriodo.where((t) {
        if (t.tipoTransaccion != TipoTransaccion.gasto) return false;
        if (t.estado != EstadoTransaccion.aprobada) return false;
        // categoriaId == null → presupuesto total, todos los gastos aplican.
        if (presupuesto.categoriaId == null) return true;
        return t.categoria.id == presupuesto.categoriaId;
      });

      var gastadoDop = 0.0;
      var usdSinConsolidar = false;
      for (final t in gastosRelevantes) {
        if (t.moneda == Moneda.dop) {
          gastadoDop += t.monto;
        } else if (tasaCambioReferencia != null) {
          gastadoDop += t.monto * tasaCambioReferencia;
        } else {
          usdSinConsolidar = true;
        }
      }

      return ProgresoPresupuesto(
        presupuesto: presupuesto,
        categoria: presupuesto.categoriaId == null
            ? null
            : categoriasPorId[presupuesto.categoriaId],
        gastadoDop: gastadoDop,
        usdSinConsolidar: usdSinConsolidar,
      );
    }).toList();
  }
}

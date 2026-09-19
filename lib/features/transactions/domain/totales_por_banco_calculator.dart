import 'entities/total_banco.dart';
import 'entities/transaccion_registro.dart';
import 'totales_transacciones_calculator.dart';

/// Agrupa el total del rango filtrado por banco (sección 9.4 de
/// CLAUDE.md — "se necesita saber el total por banco"). Reutiliza
/// `TotalesTransaccionesCalculator` por grupo, así que respeta la
/// misma regla de solo contar transacciones `aprobada`.
class TotalesPorBancoCalculator {
  const TotalesPorBancoCalculator();

  List<TotalBanco> calcular(List<TransaccionRegistro> transacciones) {
    final porBanco = <String, List<TransaccionRegistro>>{};
    for (final transaccion in transacciones) {
      porBanco
          .putIfAbsent(transaccion.nombreBanco, () => [])
          .add(transaccion);
    }

    const totalesCalculator = TotalesTransaccionesCalculator();
    final resultado = [
      for (final entrada in porBanco.entries)
        TotalBanco(
          nombreBanco: entrada.key,
          totales: totalesCalculator.calcular(entrada.value),
        ),
    ];
    resultado.sort((a, b) => a.nombreBanco.compareTo(b.nombreBanco));
    return resultado;
  }
}

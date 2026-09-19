import '../entities/presupuesto.dart';

abstract interface class PresupuestosRepository {
  Future<List<Presupuesto>> obtenerTodos();

  /// `categoriaId == null` crea el presupuesto total.
  Future<void> crear({
    required int? categoriaId,
    required double montoLimite,
    required DateTime fechaInicio,
  });

  Future<void> actualizarMonto({required int id, required double montoLimite});

  Future<void> eliminar(int id);
}

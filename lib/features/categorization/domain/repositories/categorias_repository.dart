import '../../../../core/domain/tipo_transaccion.dart';
import '../entities/categoria.dart';

abstract interface class CategoriasRepository {
  Future<List<Categoria>> obtenerTodas();

  /// La categoría de respaldo ("Otro" / "Otro ingreso", sembradas en la
  /// Fase 3) para cuando ninguna regla calza.
  Future<Categoria> obtenerCategoriaOtro(TipoTransaccion tipo);
}

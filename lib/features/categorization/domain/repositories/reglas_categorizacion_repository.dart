import '../entities/regla_categorizacion.dart';

abstract interface class ReglasCategorizacionRepository {
  /// Todas las reglas — la tabla es pequeña, el motor las recorre en
  /// memoria en vez de armar un `LIKE` dinámico por comercio.
  Future<List<ReglaCategorizacion>> obtenerTodas();

  /// Crea la regla si no existe una con esa palabra clave (sin
  /// distinguir mayúsculas), o actualiza su categoría si ya existe.
  Future<void> upsert({
    required String palabraClaveComercio,
    required int categoriaId,
  });
}

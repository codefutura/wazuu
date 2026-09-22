import '../../../core/domain/tipo_transaccion.dart';
import 'entities/categoria.dart';
import 'repositories/categorias_repository.dart';
import 'repositories/reglas_categorizacion_repository.dart';

/// Motor de categorización por reglas (sección 8 de CLAUDE.md) — sin
/// machine learning ni llamadas a un LLM externo con el contenido de
/// los correos, por la promesa de privacidad del producto.
class CategorizationEngine {
  CategorizationEngine(this._categorias, this._reglas);

  final CategoriasRepository _categorias;
  final ReglasCategorizacionRepository _reglas;

  /// Encuentra la categoría para `comercio` cruzando las reglas
  /// aprendidas. Si ninguna calza — o calza pero es de un tipo
  /// incompatible, ej. una regla de gasto en una transacción de
  /// ingreso — usa `categoriaSugerida` (si el parser dio una) antes de
  /// caer en "Otro"/"Otro ingreso" según `tipo`. Una regla aprendida
  /// siempre tiene prioridad sobre la sugerencia del parser: si el
  /// usuario ya recategorizó ese comercio a mano, se respeta.
  Future<Categoria> categorizar({
    required String comercio,
    required TipoTransaccion tipo,
    String? categoriaSugerida,
  }) async {
    final reglas = await _reglas.obtenerTodas();
    final categorias = await _categorias.obtenerTodas();
    final categoriasPorId = {for (final c in categorias) c.id: c};

    final comercioNormalizado = comercio.toUpperCase();
    for (final regla in reglas) {
      final categoria = categoriasPorId[regla.categoriaId];
      if (categoria == null || categoria.tipo != tipo) continue;
      if (comercioNormalizado.contains(
        regla.palabraClaveComercio.toUpperCase(),
      )) {
        return categoria;
      }
    }

    if (categoriaSugerida != null) {
      for (final categoria in categorias) {
        if (categoria.tipo == tipo && categoria.nombre == categoriaSugerida) {
          return categoria;
        }
      }
    }

    return _categorias.obtenerCategoriaOtro(tipo);
  }

  /// El usuario recategorizó una transacción a mano: crea o actualiza
  /// la regla para que la próxima transacción del mismo comercio caiga
  /// aquí automáticamente (aprendizaje simple, sección 8).
  Future<void> aprenderDeRecategorizacion({
    required String comercio,
    required int categoriaId,
  }) {
    return _reglas.upsert(
      palabraClaveComercio: _extraerPalabraClave(comercio),
      categoriaId: categoriaId,
    );
  }

  /// Los descriptores de comercio de tarjeta suelen traer un código de
  /// referencia después de un "*" (ej. "FACEBK *ARQPC7AZK4", visto en
  /// un correo real de BHD) — se descarta para que la regla generalice
  /// a futuras transacciones del mismo comercio, no solo a esta.
  static String _extraerPalabraClave(String comercio) {
    final trimmed = comercio.trim();
    final asteriskIndex = trimmed.indexOf('*');
    if (asteriskIndex <= 0) return trimmed;
    return trimmed.substring(0, asteriskIndex).trim();
  }
}

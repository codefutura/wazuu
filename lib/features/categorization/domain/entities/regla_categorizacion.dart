/// Regla de categorización aprendida (sección 8 de CLAUDE.md): si el
/// comercio de una transacción contiene `palabraClaveComercio`
/// (comparación sin distinguir mayúsculas), se asigna `categoriaId`.
class ReglaCategorizacion {
  const ReglaCategorizacion({
    required this.id,
    required this.palabraClaveComercio,
    required this.categoriaId,
  });

  final int id;
  final String palabraClaveComercio;
  final int categoriaId;
}

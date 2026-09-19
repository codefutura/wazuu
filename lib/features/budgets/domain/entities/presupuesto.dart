/// Fila de la tabla `presupuestos` (sección 6 de CLAUDE.md).
///
/// `categoriaId == null` significa presupuesto total (no por
/// categoría). `periodo` siempre es "mensual" — el esquema no admite
/// otro valor todavía, así que no se modela como campo.
class Presupuesto {
  const Presupuesto({
    required this.id,
    required this.categoriaId,
    required this.montoLimite,
    required this.fechaInicio,
  });

  final int id;
  final int? categoriaId;
  final double montoLimite;
  final DateTime fechaInicio;
}

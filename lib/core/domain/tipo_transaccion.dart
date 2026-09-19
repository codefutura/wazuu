/// Gasto o ingreso — usado tanto por `categorias.tipo` como por
/// `transacciones.tipo_transaccion` (sección 6 de CLAUDE.md), por eso
/// vive en `core` y no dentro de una sola feature.
enum TipoTransaccion { gasto, ingreso }

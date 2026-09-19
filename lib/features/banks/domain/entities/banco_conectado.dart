/// Fila real de `bancos_conectados` — a diferencia de `BankOption`
/// (catálogo estático), este trae el `id` de la base de datos, el que
/// referencia `tarjetas.banco_id` y `transacciones.banco_id`.
class BancoConectado {
  const BancoConectado({
    required this.id,
    required this.nombreBanco,
    required this.remitenteEmail,
  });

  final int id;
  final String nombreBanco;

  /// El motor de sincronización lo usa para armar la búsqueda en Gmail
  /// (sección 7 de CLAUDE.md: solo procesar correos de remitentes en
  /// esta tabla).
  final String remitenteEmail;
}

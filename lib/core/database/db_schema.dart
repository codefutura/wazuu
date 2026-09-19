/// Nombres de tablas y columnas del esquema SQLite (sección 6 de
/// CLAUDE.md). Centralizados aquí para que los futuros DAOs de cada
/// feature no repitan strings sueltos.
abstract final class DbSchema {
  static const version = 2;
}

abstract final class UsuariosTable {
  static const table = 'usuarios';
  static const id = 'id';
  static const email = 'email';
  static const passwordHash = 'password_hash';
  static const passwordSalt = 'password_salt';
  static const tasaCambioReferencia = 'tasa_cambio_referencia';
  static const fechaActualizacionTasa = 'fecha_actualizacion_tasa';
}

abstract final class BancosConectadosTable {
  static const table = 'bancos_conectados';
  static const id = 'id';
  static const nombreBanco = 'nombre_banco';
  static const remitenteEmail = 'remitente_email';
  static const activo = 'activo';
}

abstract final class TarjetasTable {
  static const table = 'tarjetas';
  static const id = 'id';
  static const apodo = 'apodo';
  static const ultimos4Digitos = 'ultimos_4_digitos';
  static const tipo = 'tipo';
  static const bancoId = 'banco_id';
  static const limiteCredito = 'limite_credito';
  static const fechaCorte = 'fecha_corte';
  static const fechaPago = 'fecha_pago';
}

abstract final class CategoriasTable {
  static const table = 'categorias';
  static const id = 'id';
  static const nombre = 'nombre';
  static const tipo = 'tipo';
  static const color = 'color';
  static const icono = 'icono';
}

abstract final class ReglasCategorizacionTable {
  static const table = 'reglas_categorizacion';
  static const id = 'id';
  static const palabraClaveComercio = 'palabra_clave_comercio';
  static const categoriaId = 'categoria_id';
}

abstract final class TransaccionesTable {
  static const table = 'transacciones';
  static const id = 'id';
  static const monto = 'monto';
  static const moneda = 'moneda';
  static const fecha = 'fecha';
  static const comercio = 'comercio';
  static const estado = 'estado';
  static const tipoTransaccion = 'tipo_transaccion';
  static const categoriaId = 'categoria_id';
  static const tarjetaId = 'tarjeta_id';
  static const bancoId = 'banco_id';
  static const emailIdOrigen = 'email_id_origen';
  static const hashDedupe = 'hash_dedupe';

  /// Últimos 4 dígitos leídos del correo, guardados aparte de
  /// `tarjeta_id`: si al sincronizar todavía no existía la tarjeta,
  /// esto permite vincular la transacción retroactivamente cuando el
  /// usuario la agregue después (ver `reasignarTarjetaHuerfanas`).
  static const tarjetaUltimos4Digitos = 'tarjeta_ultimos_4_digitos';
}

abstract final class PresupuestosTable {
  static const table = 'presupuestos';
  static const id = 'id';
  static const categoriaId = 'categoria_id';
  static const montoLimite = 'monto_limite';
  static const periodo = 'periodo';
  static const fechaInicio = 'fecha_inicio';
}

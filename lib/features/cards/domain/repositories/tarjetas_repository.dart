import '../entities/tarjeta.dart';

abstract interface class TarjetasRepository {
  Future<List<Tarjeta>> obtenerTodas();

  Future<void> crear({
    required String apodo,
    required String ultimos4Digitos,
    required TipoTarjeta tipo,
    required int bancoId,
    double? limiteCredito,
    DateTime? fechaCorte,
    DateTime? fechaPago,
  });

  Future<void> actualizar({
    required int id,
    required String apodo,
    double? limiteCredito,
    DateTime? fechaCorte,
    DateTime? fechaPago,
  });

  Future<void> eliminar(int id);

  /// `null` si el correo no se pudo asociar a ninguna tarjeta conocida
  /// (sección 6 de CLAUDE.md — `tarjeta_id` de `transacciones` es
  /// nullable justo por esto).
  Future<Tarjeta?> obtenerPorUltimos4Digitos({
    required int bancoId,
    required String ultimos4Digitos,
  });
}

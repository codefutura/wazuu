import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../bank_parsers/domain/entities/raw_email.dart';
import '../../bank_parsers/domain/parsers/bank_email_parser_registry.dart';
import '../../banks/domain/entities/banco_conectado.dart';
import '../../banks/domain/entities/bank_option.dart';
import '../../banks/domain/repositories/banks_repository.dart';
import '../../cards/domain/repositories/tarjetas_repository.dart';
import '../../categorization/domain/categorization_engine.dart';
import '../../gmail/domain/entities/gmail_connection.dart';
import '../../gmail/domain/repositories/gmail_auth_repository.dart';
import '../../transactions/domain/repositories/transacciones_repository.dart';
import 'entities/sync_result.dart';
import 'exceptions/gmail_quota_exceeded_exception.dart';
import 'repositories/gmail_messages_fetcher.dart';
import 'repositories/sync_state_repository.dart';

/// Conecta Gmail (Fase 4) + parsers (Fase 5) + categorización (Fase 6)
/// + `transacciones` (Fase 3): busca correos nuevos de los bancos
/// conectados, los interpreta, y los guarda.
///
/// Se dispara manualmente desde la UI — no hay sincronización en
/// segundo plano (necesitaría registrar tareas nativas, fuera del
/// alcance de las 10 fases de CLAUDE.md).
class GmailSyncService {
  const GmailSyncService({
    required this.gmailAuthRepository,
    required this.messagesFetcher,
    required this.banksRepository,
    required this.tarjetasRepository,
    required this.categorizationEngine,
    required this.transaccionesRepository,
    required this.syncStateRepository,
    required this.parserRegistry,
  });

  final GmailAuthRepository gmailAuthRepository;
  final GmailMessagesFetcher messagesFetcher;
  final BanksRepository banksRepository;
  final TarjetasRepository tarjetasRepository;
  final CategorizationEngine categorizationEngine;
  final TransaccionesRepository transaccionesRepository;
  final SyncStateRepository syncStateRepository;
  final BankEmailParserRegistry parserRegistry;

  /// `onProgress` reporta (correos procesados, total) mientras se
  /// recorren los correos nuevos — la UI lo usa para mostrar un
  /// porcentaje real en vez de un spinner indeterminado (sección 4 de
  /// CLAUDE.md: "carga progresiva, no bloqueante").
  Future<SyncResult> sincronizar({
    void Function(int procesados, int total)? onProgress,
  }) async {
    final conexion = await gmailAuthRepository.obtenerConexionValida();
    if (conexion == null) {
      return const SyncResult(
        transaccionesNuevas: 0,
        error: 'Conecta tu Gmail para sincronizar tus correos bancarios.',
      );
    }

    final bancos = await banksRepository.obtenerConectados();
    if (bancos.isEmpty) {
      return const SyncResult(
        transaccionesNuevas: 0,
        error: 'No tienes bancos conectados todavía.',
      );
    }

    final ultimaSincronizacion = await syncStateRepository
        .obtenerUltimaSincronizacion();

    List<String> ids;
    try {
      ids = await messagesFetcher.listarIds(
        accessToken: conexion.accessToken,
        remitentes: bancos.map((b) => b.remitenteEmail).toList(),
        despues: ultimaSincronizacion,
      );
    } on GmailQuotaExceededException {
      return const SyncResult(
        transaccionesNuevas: 0,
        error: _mensajeCuotaExcedida,
      );
    }

    // `after:` de Gmail solo filtra por día completo, así que
    // `listarIds` puede devolver correos que ya se sincronizaron antes
    // en el mismo día — se descartan aquí, antes de pedirle su
    // contenido completo a Gmail, para no re-descargar ni re-parsear
    // lo que ya se guardó.
    final yaSincronizados = await transaccionesRepository
        .obtenerEmailIdsExistentes(ids);

    var nuevas = 0;
    var cuotaAgotada = false;
    onProgress?.call(0, ids.length);
    for (var i = 0; i < ids.length; i++) {
      try {
        final id = ids[i];
        if (yaSincronizados.contains(id)) continue;

        RawEmail email;
        try {
          email = await messagesFetcher.obtenerCorreo(
            accessToken: conexion.accessToken,
            messageId: id,
          );
        } on GmailQuotaExceededException {
          // Se detiene aquí sin marcar la sincronización como
          // completa (no se actualiza `ultimaSincronizacion`), así el
          // próximo intento recoge los correos que faltaron — los ya
          // guardados no se vuelven a pedir gracias a
          // `yaSincronizados`.
          cuotaAgotada = true;
          break;
        }

        final match = parserRegistry.parse(email);
        if (match == null) continue;

        final banco = _bancoParaOpcion(bancos, match.bankOptionId);
        if (banco == null) continue;

        final categoria = await categorizationEngine.categorizar(
          comercio: match.transaccion.comercio,
          tipo: match.transaccion.tipoTransaccion,
        );

        int? tarjetaId;
        final ultimos4 = match.transaccion.tarjetaUltimos4Digitos;
        if (ultimos4 != null) {
          final tarjeta = await tarjetasRepository.obtenerPorUltimos4Digitos(
            bancoId: banco.id,
            ultimos4Digitos: ultimos4,
          );
          tarjetaId = tarjeta?.id;
        }

        final insertada = await transaccionesRepository.insertar(
          monto: match.transaccion.monto,
          moneda: match.transaccion.moneda,
          fecha: match.transaccion.fecha,
          comercio: match.transaccion.comercio,
          estado: match.transaccion.estado,
          tipoTransaccion: match.transaccion.tipoTransaccion,
          categoriaId: categoria.id,
          tarjetaId: tarjetaId,
          bancoId: banco.id,
          emailIdOrigen: match.transaccion.emailIdOrigen,
          hashDedupe: _hashDedupe(
            monto: match.transaccion.monto,
            fecha: match.transaccion.fecha,
            comercio: match.transaccion.comercio,
            bancoId: banco.id,
          ),
          tarjetaUltimos4Digitos: ultimos4,
        );
        if (insertada) nuevas++;
      } finally {
        onProgress?.call(i + 1, ids.length);
      }
    }

    // Si ya se agotó la cuota, un llamado más (aunque sea para
    // reparación de vínculos) solo repetiría el mismo error.
    final vinculadas = cuotaAgotada
        ? 0
        : await _repararVinculosDeTarjeta(conexion: conexion, bancos: bancos);

    if (!cuotaAgotada) {
      await syncStateRepository.registrarSincronizacion(DateTime.now());
    }

    return SyncResult(
      transaccionesNuevas: nuevas,
      transaccionesVinculadas: vinculadas,
      error: cuotaAgotada ? _mensajeCuotaExcedida : null,
    );
  }

  static const _mensajeCuotaExcedida =
      'Gmail limitó las solicitudes por unos minutos. Se guardó lo que '
      'alcanzó a procesar — vuelve a sincronizar en un momento para '
      'traer el resto.';

  /// Transacciones que se sincronizaron antes de guardar
  /// `tarjeta_ultimos_4_digitos` (o antes de que su tarjeta existiera)
  /// quedaron huérfanas sin forma de repararse solas — se les vuelve a
  /// pedir su correo original a Gmail (por `emailIdOrigen`) y se
  /// re-parsea solo para recuperar el dato que falta. Alcance acotado
  /// a los pocos huérfanos reales, no a todo el historial.
  Future<int> _repararVinculosDeTarjeta({
    required GmailConnection conexion,
    required List<BancoConectado> bancos,
  }) async {
    var vinculadas = 0;
    for (final banco in bancos) {
      final huerfanas = await transaccionesRepository.obtenerHuerfanasPorBanco(
        banco.id,
      );
      for (final huerfana in huerfanas) {
        final email = await messagesFetcher.obtenerCorreo(
          accessToken: conexion.accessToken,
          messageId: huerfana.emailIdOrigen,
        );
        final ultimos4 = parserRegistry.parse(email)?.transaccion.tarjetaUltimos4Digitos;
        if (ultimos4 == null) continue;

        final tarjeta = await tarjetasRepository.obtenerPorUltimos4Digitos(
          bancoId: banco.id,
          ultimos4Digitos: ultimos4,
        );
        if (tarjeta == null) continue;

        await transaccionesRepository.vincularTarjeta(
          transaccionId: huerfana.id,
          tarjetaId: tarjeta.id,
          tarjetaUltimos4Digitos: ultimos4,
        );
        vinculadas++;
      }
    }
    return vinculadas;
  }

  /// El correo trae el remitente real, pero el parser solo sabe decir
  /// "esto es de Popular/BHD" (`bankOptionId` del catálogo) — se cruza
  /// contra el catálogo para encontrar el banco conectado real.
  BancoConectado? _bancoParaOpcion(
    List<BancoConectado> bancosConectados,
    String bankOptionId,
  ) {
    String? nombreEsperado;
    for (final opcion in supportedBanksCatalog) {
      if (opcion.id == bankOptionId) {
        nombreEsperado = opcion.name;
        break;
      }
    }
    if (nombreEsperado == null) return null;

    for (final banco in bancosConectados) {
      if (banco.nombreBanco == nombreEsperado) return banco;
    }
    return null;
  }

  /// Clave de deduplicación: monto + fecha + comercio + banco_id
  /// (sección 6 de CLAUDE.md).
  String _hashDedupe({
    required double monto,
    required DateTime fecha,
    required String comercio,
    required int bancoId,
  }) {
    final texto =
        '${monto.toStringAsFixed(2)}|${fecha.toIso8601String()}|'
        '${comercio.trim().toUpperCase()}|$bancoId';
    return sha256.convert(utf8.encode(texto)).toString();
  }
}

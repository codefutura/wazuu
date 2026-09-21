import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wazuu/core/domain/estado_transaccion.dart';
import 'package:wazuu/core/domain/moneda.dart';
import 'package:wazuu/core/domain/tipo_transaccion.dart';
import 'package:wazuu/features/bank_parsers/data/parsers/default_bank_email_parser_registry.dart';
import 'package:wazuu/features/bank_parsers/domain/entities/raw_email.dart';
import 'package:wazuu/features/banks/domain/entities/banco_conectado.dart';
import 'package:wazuu/features/banks/domain/entities/bank_option.dart';
import 'package:wazuu/features/banks/domain/repositories/banks_repository.dart';
import 'package:wazuu/features/cards/domain/entities/tarjeta.dart';
import 'package:wazuu/features/cards/domain/repositories/tarjetas_repository.dart';
import 'package:wazuu/features/categorization/domain/categorization_engine.dart';
import 'package:wazuu/features/categorization/domain/entities/categoria.dart';
import 'package:wazuu/features/categorization/domain/entities/regla_categorizacion.dart';
import 'package:wazuu/features/categorization/domain/repositories/categorias_repository.dart';
import 'package:wazuu/features/categorization/domain/repositories/reglas_categorizacion_repository.dart';
import 'package:wazuu/features/gmail/domain/entities/gmail_connection.dart';
import 'package:wazuu/features/gmail/domain/repositories/gmail_auth_repository.dart';
import 'package:wazuu/features/sync/domain/exceptions/gmail_quota_exceeded_exception.dart';
import 'package:wazuu/features/sync/domain/gmail_sync_service.dart';
import 'package:wazuu/features/sync/domain/repositories/gmail_messages_fetcher.dart';
import 'package:wazuu/features/sync/domain/repositories/sync_state_repository.dart';
import 'package:wazuu/features/transactions/domain/entities/transaccion_huerfana.dart';
import 'package:wazuu/features/transactions/domain/entities/transaccion_registro.dart';
import 'package:wazuu/features/transactions/domain/repositories/transacciones_repository.dart';

class _FakeGmailAuthRepository implements GmailAuthRepository {
  _FakeGmailAuthRepository(this._conexion);

  final GmailConnection? _conexion;

  @override
  Future<GmailConnection?> obtenerConexionValida() async => _conexion;

  @override
  Future<GmailConnection?> currentConnection() =>
      throw UnimplementedError();

  @override
  Future<GmailConnection> connect() => throw UnimplementedError();

  @override
  Future<void> disconnect() => throw UnimplementedError();
}

class _FakeGmailMessagesFetcher implements GmailMessagesFetcher {
  _FakeGmailMessagesFetcher(
    this._correosPorId, {
    List<String>? idsNuevos,
    Set<String> idsConCuotaExcedida = const {},
  }) : _idsNuevos = idsNuevos ?? _correosPorId.keys.toList(),
       _idsConCuotaExcedida = idsConCuotaExcedida;

  final Map<String, RawEmail> _correosPorId;
  // Separado de `_correosPorId`: la reparación de vínculos re-pide un
  // correo por id directamente (sin pasar por `listarIds`), así que un
  // test puede simular "sin mensajes nuevos" y aun así dejar ese correo
  // disponible para re-parsearse.
  final List<String> _idsNuevos;
  final Set<String> _idsConCuotaExcedida;
  List<String>? remitentesRecibidos;
  DateTime? despuesRecibido;
  final List<String> idsPedidos = [];

  @override
  Future<List<String>> listarIds({
    required String accessToken,
    required List<String> remitentes,
    DateTime? despues,
  }) async {
    remitentesRecibidos = remitentes;
    despuesRecibido = despues;
    return _idsNuevos;
  }

  @override
  Future<RawEmail> obtenerCorreo({
    required String accessToken,
    required String messageId,
  }) async {
    if (_idsConCuotaExcedida.contains(messageId)) {
      throw const GmailQuotaExceededException();
    }
    idsPedidos.add(messageId);
    return _correosPorId[messageId]!;
  }
}

class _FakeBanksRepository implements BanksRepository {
  _FakeBanksRepository(this._conectados);

  final List<BancoConectado> _conectados;

  @override
  Future<List<BancoConectado>> obtenerConectados() async => _conectados;

  @override
  List<BankOption> supportedBanks() => throw UnimplementedError();

  @override
  Future<void> saveConnectedBanks(Set<String> bankIds) =>
      throw UnimplementedError();

  @override
  Future<Set<String>> connectedBankIds() => throw UnimplementedError();
}

class _FakeTarjetasRepository implements TarjetasRepository {
  Map<String, Tarjeta> tarjetasPorClave = {};

  @override
  Future<Tarjeta?> obtenerPorUltimos4Digitos({
    required int bancoId,
    required String ultimos4Digitos,
  }) async => tarjetasPorClave['$bancoId-$ultimos4Digitos'];

  @override
  Future<List<Tarjeta>> obtenerTodas() => throw UnimplementedError();

  @override
  Future<void> crear({
    required String apodo,
    required String ultimos4Digitos,
    required TipoTarjeta tipo,
    required int bancoId,
    double? limiteCredito,
    DateTime? fechaCorte,
    DateTime? fechaPago,
  }) => throw UnimplementedError();

  @override
  Future<void> actualizar({
    required int id,
    required String apodo,
    double? limiteCredito,
    DateTime? fechaCorte,
    DateTime? fechaPago,
  }) => throw UnimplementedError();

  @override
  Future<void> eliminar(int id) => throw UnimplementedError();
}

class _FakeTransaccionesRepository implements TransaccionesRepository {
  final List<String> hashesInsertados = [];
  final List<String?> ultimos4Insertados = [];
  final Set<String> emailIdsInsertados = {};
  Map<int, List<TransaccionHuerfana>> huerfanasPorBanco = {};
  final List<({int transaccionId, int tarjetaId, String ultimos4})>
  vinculaciones = [];

  @override
  Future<bool> insertar({
    required double monto,
    required Moneda moneda,
    required DateTime fecha,
    required String comercio,
    required EstadoTransaccion estado,
    required TipoTransaccion tipoTransaccion,
    required int categoriaId,
    int? tarjetaId,
    required int bancoId,
    required String emailIdOrigen,
    required String hashDedupe,
    String? tarjetaUltimos4Digitos,
  }) async {
    if (hashesInsertados.contains(hashDedupe)) return false;
    hashesInsertados.add(hashDedupe);
    ultimos4Insertados.add(tarjetaUltimos4Digitos);
    emailIdsInsertados.add(emailIdOrigen);
    return true;
  }

  @override
  Future<Set<String>> obtenerEmailIdsExistentes(List<String> ids) async {
    return ids.where(emailIdsInsertados.contains).toSet();
  }

  @override
  Future<int> reasignarTarjetaHuerfanas({
    required int bancoId,
    required String ultimos4Digitos,
    required int tarjetaId,
  }) => throw UnimplementedError();

  @override
  Future<List<TransaccionHuerfana>> obtenerHuerfanasPorBanco(
    int bancoId,
  ) async => huerfanasPorBanco[bancoId] ?? [];

  @override
  Future<void> vincularTarjeta({
    required int transaccionId,
    required int tarjetaId,
    required String tarjetaUltimos4Digitos,
  }) async {
    vinculaciones.add((
      transaccionId: transaccionId,
      tarjetaId: tarjetaId,
      ultimos4: tarjetaUltimos4Digitos,
    ));
  }

  @override
  Future<List<TransaccionRegistro>> obtener({
    DateTime? desde,
    DateTime? hasta,
    int? categoriaId,
    int? tarjetaId,
  }) => throw UnimplementedError();

  @override
  Future<void> actualizarCategoria({
    required int transaccionId,
    required int categoriaId,
  }) => throw UnimplementedError();
}

class _FakeSyncStateRepository implements SyncStateRepository {
  DateTime? ultima;
  DateTime? registrada;

  @override
  Future<DateTime?> obtenerUltimaSincronizacion() async => ultima;

  @override
  Future<void> registrarSincronizacion(DateTime momento) async {
    registrada = momento;
  }
}

class _FakeCategoriasRepository implements CategoriasRepository {
  static const _otroGasto = Categoria(
    id: 1,
    nombre: 'Otro',
    tipo: TipoTransaccion.gasto,
    color: '#999999',
    icono: 'help',
  );

  @override
  Future<List<Categoria>> obtenerTodas() async => const [_otroGasto];

  @override
  Future<Categoria> obtenerCategoriaOtro(TipoTransaccion tipo) async =>
      _otroGasto;
}

class _FakeReglasCategorizacionRepository
    implements ReglasCategorizacionRepository {
  @override
  Future<List<ReglaCategorizacion>> obtenerTodas() async => const [];

  @override
  Future<void> upsert({
    required String palabraClaveComercio,
    required int categoriaId,
  }) => throw UnimplementedError();
}

void main() {
  final correoPopular = RawEmail(
    id: 'msg-popular-1',
    from: 'notificaciones@popularenlinea.com',
    subject: 'Notificación de Consumo',
    plainTextBody: File(
      'test/fixtures/bank_emails/popular_gasto.txt',
    ).readAsStringSync(),
  );

  const bancoPopularConectado = BancoConectado(
    id: 42,
    nombreBanco: 'Banco Popular Dominicano',
    remitenteEmail: 'alertas@popular.com.do',
  );

  GmailSyncService construirServicio({
    GmailConnection? conexion,
    required Map<String, RawEmail> correos,
    List<String>? idsNuevos,
    List<BancoConectado> bancos = const [bancoPopularConectado],
    _FakeTransaccionesRepository? transaccionesRepository,
    _FakeSyncStateRepository? syncStateRepository,
    _FakeTarjetasRepository? tarjetasRepository,
    _FakeGmailMessagesFetcher? messagesFetcher,
  }) {
    return GmailSyncService(
      gmailAuthRepository: _FakeGmailAuthRepository(conexion),
      messagesFetcher:
          messagesFetcher ??
          _FakeGmailMessagesFetcher(correos, idsNuevos: idsNuevos),
      banksRepository: _FakeBanksRepository(bancos),
      tarjetasRepository: tarjetasRepository ?? _FakeTarjetasRepository(),
      categorizationEngine: CategorizationEngine(
        _FakeCategoriasRepository(),
        _FakeReglasCategorizacionRepository(),
      ),
      transaccionesRepository:
          transaccionesRepository ?? _FakeTransaccionesRepository(),
      syncStateRepository: syncStateRepository ?? _FakeSyncStateRepository(),
      parserRegistry: defaultBankEmailParserRegistry,
    );
  }

  test('sin conexión de Gmail, devuelve error y no busca correos', () async {
    final servicio = construirServicio(conexion: null, correos: {});

    final resultado = await servicio.sincronizar();

    expect(resultado.transaccionesNuevas, 0);
    expect(resultado.error, isNotNull);
  });

  test('sin bancos conectados, devuelve error', () async {
    final servicio = construirServicio(
      conexion: GmailConnection(
        email: 'yo@gmail.com',
        accessToken: 'token',
        accessTokenExpiry: DateTime.now().add(const Duration(hours: 1)),
      ),
      correos: {},
      bancos: const [],
    );

    final resultado = await servicio.sincronizar();

    expect(resultado.transaccionesNuevas, 0);
    expect(resultado.error, isNotNull);
  });

  test(
    'un correo real de Popular se parsea, categoriza e inserta',
    () async {
      final transacciones = _FakeTransaccionesRepository();
      final estadoSync = _FakeSyncStateRepository();
      final servicio = construirServicio(
        conexion: GmailConnection(
          email: 'yo@gmail.com',
          accessToken: 'token',
          accessTokenExpiry: DateTime.now().add(const Duration(hours: 1)),
        ),
        correos: {'msg-popular-1': correoPopular},
        transaccionesRepository: transacciones,
        syncStateRepository: estadoSync,
      );

      final resultado = await servicio.sincronizar();

      expect(resultado.error, isNull);
      expect(resultado.transaccionesNuevas, 1);
      expect(transacciones.hashesInsertados, hasLength(1));
      expect(estadoSync.registrada, isNotNull);
    },
  );

  test('un correo ya visto (mismo hash) no se cuenta dos veces', () async {
    final transacciones = _FakeTransaccionesRepository();
    final servicio = construirServicio(
      conexion: GmailConnection(
        email: 'yo@gmail.com',
        accessToken: 'token',
        accessTokenExpiry: DateTime.now().add(const Duration(hours: 1)),
      ),
      correos: {'msg-popular-1': correoPopular},
      transaccionesRepository: transacciones,
    );

    await servicio.sincronizar();
    final segundaCorrida = await servicio.sincronizar();

    expect(segundaCorrida.transaccionesNuevas, 0);
  });

  test(
    'un correo ya sincronizado no se vuelve a pedir a Gmail en el '
    'siguiente sync (aunque `listarIds` lo vuelva a devolver, por el '
    'filtro de solo-día de Gmail)',
    () async {
      final transacciones = _FakeTransaccionesRepository();
      final fetcher = _FakeGmailMessagesFetcher({
        'msg-popular-1': correoPopular,
      });
      final servicio = construirServicio(
        conexion: GmailConnection(
          email: 'yo@gmail.com',
          accessToken: 'token',
          accessTokenExpiry: DateTime.now().add(const Duration(hours: 1)),
        ),
        correos: {'msg-popular-1': correoPopular},
        transaccionesRepository: transacciones,
        messagesFetcher: fetcher,
      );

      await servicio.sincronizar();
      expect(fetcher.idsPedidos, ['msg-popular-1']);

      final segundaCorrida = await servicio.sincronizar();

      expect(segundaCorrida.transaccionesNuevas, 0);
      // El segundo sync no debió pedir de nuevo el correo ya guardado.
      expect(fetcher.idsPedidos, ['msg-popular-1']);
    },
  );

  test(
    'si Gmail agota la cuota a mitad de la sincronización, se detiene '
    'ahí, guarda lo que alcanzó a procesar, y no marca la '
    'sincronización como completa (para reintentar el resto después)',
    () async {
      final transacciones = _FakeTransaccionesRepository();
      final syncState = _FakeSyncStateRepository();
      final correoPopular2 = RawEmail(
        id: 'msg-popular-2',
        from: correoPopular.from,
        subject: correoPopular.subject,
        plainTextBody: correoPopular.plainTextBody,
      );
      final fetcher = _FakeGmailMessagesFetcher(
        {'msg-popular-1': correoPopular, 'msg-popular-2': correoPopular2},
        idsNuevos: ['msg-popular-1', 'msg-popular-2'],
        idsConCuotaExcedida: {'msg-popular-2'},
      );
      final servicio = construirServicio(
        conexion: GmailConnection(
          email: 'yo@gmail.com',
          accessToken: 'token',
          accessTokenExpiry: DateTime.now().add(const Duration(hours: 1)),
        ),
        correos: {},
        transaccionesRepository: transacciones,
        syncStateRepository: syncState,
        messagesFetcher: fetcher,
      );

      final resultado = await servicio.sincronizar();

      expect(resultado.transaccionesNuevas, 1);
      expect(resultado.error, isNotNull);
      expect(transacciones.hashesInsertados, hasLength(1));
      expect(syncState.registrada, isNull);
    },
  );

  test('un correo que ningún parser reconoce se ignora', () async {
    final servicio = construirServicio(
      conexion: GmailConnection(
        email: 'yo@gmail.com',
        accessToken: 'token',
        accessTokenExpiry: DateTime.now().add(const Duration(hours: 1)),
      ),
      correos: {
        'msg-desconocido': const RawEmail(
          id: 'msg-desconocido',
          from: 'alguien@otrobanco.com',
          subject: 'Sin relación',
          plainTextBody: 'Contenido irrelevante',
        ),
      },
    );

    final resultado = await servicio.sincronizar();

    expect(resultado.transaccionesNuevas, 0);
    expect(resultado.error, isNull);
  });

  group('reparación de vínculos de tarjeta', () {
    test(
      'vincula una transacción huérfana cuya tarjeta ya existe, '
      're-parseando su correo original',
      () async {
        final transacciones = _FakeTransaccionesRepository()
          ..huerfanasPorBanco = {
            bancoPopularConectado.id: [
              const TransaccionHuerfana(
                id: 7,
                emailIdOrigen: 'msg-popular-1',
              ),
            ],
          };
        const tarjeta = Tarjeta(
          id: 3,
          apodo: 'Visa Gold',
          ultimos4Digitos: '2319',
          tipo: TipoTarjeta.credito,
          bancoId: 42,
          nombreBanco: 'Banco Popular Dominicano',
        );
        final tarjetas = _FakeTarjetasRepository()
          ..tarjetasPorClave = {'42-2319': tarjeta};

        final servicio = construirServicio(
          conexion: GmailConnection(
            email: 'yo@gmail.com',
            accessToken: 'token',
            accessTokenExpiry: DateTime.now().add(const Duration(hours: 1)),
          ),
          correos: {'msg-popular-1': correoPopular},
          idsNuevos: [],
          transaccionesRepository: transacciones,
          tarjetasRepository: tarjetas,
        );

        final resultado = await servicio.sincronizar();

        expect(resultado.transaccionesNuevas, 0);
        expect(resultado.transaccionesVinculadas, 1);
        expect(transacciones.vinculaciones, hasLength(1));
        expect(transacciones.vinculaciones.single.transaccionId, 7);
        expect(transacciones.vinculaciones.single.tarjetaId, 3);
      },
    );

    test(
      'una huérfana cuya tarjeta todavía no existe se deja como está',
      () async {
        final transacciones = _FakeTransaccionesRepository()
          ..huerfanasPorBanco = {
            bancoPopularConectado.id: [
              const TransaccionHuerfana(
                id: 7,
                emailIdOrigen: 'msg-popular-1',
              ),
            ],
          };

        final servicio = construirServicio(
          conexion: GmailConnection(
            email: 'yo@gmail.com',
            accessToken: 'token',
            accessTokenExpiry: DateTime.now().add(const Duration(hours: 1)),
          ),
          correos: {'msg-popular-1': correoPopular},
          idsNuevos: [],
          transaccionesRepository: transacciones,
        );

        final resultado = await servicio.sincronizar();

        expect(resultado.transaccionesVinculadas, 0);
        expect(transacciones.vinculaciones, isEmpty);
      },
    );
  });
}

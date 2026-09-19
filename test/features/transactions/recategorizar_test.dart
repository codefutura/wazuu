import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wazuu/core/domain/estado_transaccion.dart';
import 'package:wazuu/core/domain/moneda.dart';
import 'package:wazuu/core/domain/tipo_transaccion.dart';
import 'package:wazuu/core/theme/app_theme.dart';
import 'package:wazuu/features/cards/data/providers/tarjetas_repository_provider.dart';
import 'package:wazuu/features/cards/domain/entities/tarjeta.dart';
import 'package:wazuu/features/cards/domain/repositories/tarjetas_repository.dart';
import 'package:wazuu/features/categorization/data/providers/categorization_providers.dart';
import 'package:wazuu/features/categorization/domain/entities/categoria.dart';
import 'package:wazuu/features/categorization/domain/entities/regla_categorizacion.dart';
import 'package:wazuu/features/categorization/domain/repositories/categorias_repository.dart';
import 'package:wazuu/features/categorization/domain/repositories/reglas_categorizacion_repository.dart';
import 'package:wazuu/features/transactions/data/providers/transacciones_repository_provider.dart';
import 'package:wazuu/features/transactions/domain/entities/transaccion_huerfana.dart';
import 'package:wazuu/features/transactions/domain/entities/transaccion_registro.dart';
import 'package:wazuu/features/transactions/domain/repositories/transacciones_repository.dart';
import 'package:wazuu/features/transactions/presentation/screens/transactions_list_screen.dart';

const _compras = Categoria(
  id: 1,
  nombre: 'Compras',
  tipo: TipoTransaccion.gasto,
  color: '#0F766E',
  icono: 'shopping_bag',
);
const _alimentos = Categoria(
  id: 2,
  nombre: 'Alimentos',
  tipo: TipoTransaccion.gasto,
  color: '#F59E0B',
  icono: 'restaurant',
);
const _nomina = Categoria(
  id: 8,
  nombre: 'Nómina',
  tipo: TipoTransaccion.ingreso,
  color: '#22C55E',
  icono: 'payments',
);

class _FakeTransaccionesRepository implements TransaccionesRepository {
  late TransaccionRegistro transaccion;

  ({int transaccionId, int categoriaId})? ultimaActualizacion;

  @override
  Future<List<TransaccionRegistro>> obtener({
    DateTime? desde,
    DateTime? hasta,
    int? categoriaId,
    int? tarjetaId,
  }) async => [transaccion];

  @override
  Future<void> actualizarCategoria({
    required int transaccionId,
    required int categoriaId,
  }) async {
    ultimaActualizacion = (
      transaccionId: transaccionId,
      categoriaId: categoriaId,
    );
    transaccion = TransaccionRegistro(
      id: transaccion.id,
      monto: transaccion.monto,
      moneda: transaccion.moneda,
      fecha: transaccion.fecha,
      comercio: transaccion.comercio,
      estado: transaccion.estado,
      tipoTransaccion: transaccion.tipoTransaccion,
      categoria: categoriaId == _alimentos.id ? _alimentos : _compras,
      bancoId: transaccion.bancoId,
      nombreBanco: transaccion.nombreBanco,
    );
  }

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
  }) async => true;

  @override
  Future<int> reasignarTarjetaHuerfanas({
    required int bancoId,
    required String ultimos4Digitos,
    required int tarjetaId,
  }) async => 0;

  @override
  Future<List<TransaccionHuerfana>> obtenerHuerfanasPorBanco(
    int bancoId,
  ) async => [];

  @override
  Future<void> vincularTarjeta({
    required int transaccionId,
    required int tarjetaId,
    required String tarjetaUltimos4Digitos,
  }) async {}
}

class _FakeCategoriasRepository implements CategoriasRepository {
  @override
  Future<List<Categoria>> obtenerTodas() async => const [
    _compras,
    _alimentos,
    _nomina,
  ];

  @override
  Future<Categoria> obtenerCategoriaOtro(TipoTransaccion tipo) async =>
      tipo == TipoTransaccion.gasto ? _compras : _nomina;
}

class _FakeReglasRepository implements ReglasCategorizacionRepository {
  final List<({String palabraClaveComercio, int categoriaId})> reglas = [];

  @override
  Future<List<ReglaCategorizacion>> obtenerTodas() async => [
    for (var i = 0; i < reglas.length; i++)
      ReglaCategorizacion(
        id: i + 1,
        palabraClaveComercio: reglas[i].palabraClaveComercio,
        categoriaId: reglas[i].categoriaId,
      ),
  ];

  @override
  Future<void> upsert({
    required String palabraClaveComercio,
    required int categoriaId,
  }) async {
    reglas.removeWhere(
      (r) =>
          r.palabraClaveComercio.toUpperCase() ==
          palabraClaveComercio.toUpperCase(),
    );
    reglas.add((
      palabraClaveComercio: palabraClaveComercio,
      categoriaId: categoriaId,
    ));
  }
}

class _EmptyTarjetasRepository implements TarjetasRepository {
  @override
  Future<List<Tarjeta>> obtenerTodas() async => [];

  @override
  Future<void> crear({
    required String apodo,
    required String ultimos4Digitos,
    required TipoTarjeta tipo,
    required int bancoId,
    double? limiteCredito,
    DateTime? fechaCorte,
    DateTime? fechaPago,
  }) async {}

  @override
  Future<void> actualizar({
    required int id,
    required String apodo,
    double? limiteCredito,
    DateTime? fechaCorte,
    DateTime? fechaPago,
  }) async {}

  @override
  Future<void> eliminar(int id) async {}

  @override
  Future<Tarjeta?> obtenerPorUltimos4Digitos({
    required int bancoId,
    required String ultimos4Digitos,
  }) async => null;
}

void main() {
  testWidgets(
    'tocar una transacción permite recategorizarla y aprende la regla',
    (WidgetTester tester) async {
      final transaccionesRepo = _FakeTransaccionesRepository();
      transaccionesRepo.transaccion = TransaccionRegistro(
        id: 1,
        monto: 185.14,
        moneda: Moneda.dop,
        fecha: DateTime(2026, 9, 15),
        comercio: 'CFN FERRECENTRO',
        estado: EstadoTransaccion.aprobada,
        tipoTransaccion: TipoTransaccion.gasto,
        categoria: _compras,
        bancoId: 1,
        nombreBanco: 'Banco Popular Dominicano',
      );
      final reglasRepo = _FakeReglasRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transaccionesRepositoryProvider.overrideWith(
              (ref) async => transaccionesRepo,
            ),
            categoriasRepositoryProvider.overrideWith(
              (ref) async => _FakeCategoriasRepository(),
            ),
            reglasCategorizacionRepositoryProvider.overrideWith(
              (ref) async => reglasRepo,
            ),
            tarjetasRepositoryProvider.overrideWith(
              (ref) async => _EmptyTarjetasRepository(),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(body: TransactionsListScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Compras'), findsOneWidget);

      await tester.tap(find.text('CFN FERRECENTRO'));
      await tester.pumpAndSettle();

      expect(find.text('Elegir categoría'), findsOneWidget);
      // Solo categorías de gasto — "Nómina" (ingreso) no debe aparecer.
      expect(find.text('Nómina'), findsNothing);

      await tester.tap(find.text('Alimentos'));
      await tester.pumpAndSettle();

      expect(
        find.text('Recategorizado como "Alimentos"'),
        findsOneWidget,
      );
      expect(transaccionesRepo.ultimaActualizacion, (
        transaccionId: 1,
        categoriaId: _alimentos.id,
      ));
      expect(reglasRepo.reglas, hasLength(1));
      expect(reglasRepo.reglas.single.palabraClaveComercio, 'CFN FERRECENTRO');
      expect(reglasRepo.reglas.single.categoriaId, _alimentos.id);

      expect(tester.takeException(), isNull);
    },
  );
}

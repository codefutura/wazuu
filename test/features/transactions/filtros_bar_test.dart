import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wazuu/core/domain/tipo_transaccion.dart';
import 'package:wazuu/features/cards/data/providers/tarjetas_repository_provider.dart';
import 'package:wazuu/features/cards/domain/entities/tarjeta.dart';
import 'package:wazuu/features/cards/domain/repositories/tarjetas_repository.dart';
import 'package:wazuu/features/categorization/data/providers/categorization_providers.dart';
import 'package:wazuu/features/categorization/domain/entities/categoria.dart';
import 'package:wazuu/features/categorization/domain/repositories/categorias_repository.dart';
import 'package:wazuu/features/transactions/presentation/providers/transacciones_filtro_provider.dart';
import 'package:wazuu/features/transactions/presentation/widgets/filtros_bar.dart';

class _FakeCategoriasRepository implements CategoriasRepository {
  @override
  Future<List<Categoria>> obtenerTodas() async => const [
    Categoria(
      id: 1,
      nombre: 'Compras',
      tipo: TipoTransaccion.gasto,
      color: '#0F766E',
      icono: 'shopping_bag',
    ),
  ];

  @override
  Future<Categoria> obtenerCategoriaOtro(TipoTransaccion tipo) =>
      throw UnimplementedError();
}

class _FakeTarjetasRepository implements TarjetasRepository {
  @override
  Future<List<Tarjeta>> obtenerTodas() async => const [
    Tarjeta(
      id: 1,
      apodo: 'Visa Gold',
      ultimos4Digitos: '2319',
      tipo: TipoTarjeta.credito,
      bancoId: 1,
      nombreBanco: 'Banco Popular Dominicano',
    ),
  ];

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

  @override
  Future<Tarjeta?> obtenerPorUltimos4Digitos({
    required int bancoId,
    required String ultimos4Digitos,
  }) => throw UnimplementedError();
}

void main() {
  Future<void> pump(WidgetTester tester, TransaccionesFiltro filtro) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoriasRepositoryProvider.overrideWith(
            (ref) async => _FakeCategoriasRepository(),
          ),
          tarjetasRepositoryProvider.overrideWith(
            (ref) async => _FakeTarjetasRepository(),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: FiltrosBar(filtro: filtro)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('mes por defecto se muestra como nombre de mes', (
    tester,
  ) async {
    await pump(
      tester,
      TransaccionesFiltro(desde: DateTime(2026, 9), esRangoPorDefecto: true),
    );
    expect(find.text('Mostrando: septiembre 2026'), findsOneWidget);
  });

  testWidgets('sin filtros, avisa que muestra todo el historial', (
    tester,
  ) async {
    await pump(tester, const TransaccionesFiltro());
    expect(find.text('Mostrando todo el historial'), findsOneWidget);
  });

  testWidgets('categoría elegida se muestra por nombre', (tester) async {
    await pump(tester, const TransaccionesFiltro(categoriaId: 1));
    expect(find.text('Mostrando: Compras'), findsOneWidget);
  });

  testWidgets('tarjeta elegida se muestra por apodo', (tester) async {
    await pump(tester, const TransaccionesFiltro(tarjetaId: 1));
    expect(find.text('Mostrando: Visa Gold'), findsOneWidget);
  });

  testWidgets('rango de fechas explícito se muestra completo', (
    tester,
  ) async {
    await pump(
      tester,
      TransaccionesFiltro(desde: DateTime(2026, 1, 5), hasta: DateTime(2026, 1, 20)),
    );
    expect(find.text('Mostrando: 5/1 - 20/1'), findsOneWidget);
  });
}

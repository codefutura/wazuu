import 'package:flutter_test/flutter_test.dart';
import 'package:wazuu/features/transactions/presentation/providers/transacciones_filtro_provider.dart';

void main() {
  test(
    'el rango "mes actual" por defecto no cuenta como filtro explícito',
    () {
      final filtro = TransaccionesFiltro(
        desde: DateTime(2026, 9),
        esRangoPorDefecto: true,
      );

      expect(filtro.tieneFiltrosActivos, isTrue);
      expect(filtro.esFiltroExplicito, isFalse);
    },
  );

  test('sin ningún filtro, no es explícito', () {
    const filtro = TransaccionesFiltro();

    expect(filtro.tieneFiltrosActivos, isFalse);
    expect(filtro.esFiltroExplicito, isFalse);
  });

  test('un rango de fechas elegido por el usuario sí es explícito', () {
    final filtro = TransaccionesFiltro(
      desde: DateTime(2026, 1, 1),
      hasta: DateTime(2026, 1, 31),
    );

    expect(filtro.esFiltroExplicito, isTrue);
  });

  test('elegir una categoría es explícito aunque el rango sea el de por defecto', () {
    final filtro = TransaccionesFiltro(
      desde: DateTime(2026, 9),
      esRangoPorDefecto: true,
      categoriaId: 3,
    );

    expect(filtro.esFiltroExplicito, isTrue);
  });

  test('elegir una tarjeta es explícito', () {
    const filtro = TransaccionesFiltro(tarjetaId: 1);

    expect(filtro.esFiltroExplicito, isTrue);
  });
}

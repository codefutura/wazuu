import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/tipo_transaccion.dart';
import '../../../cards/data/providers/tarjetas_repository_provider.dart';
import '../../../cards/domain/entities/tarjeta.dart';
import '../../../categorization/data/providers/categorization_providers.dart';
import '../../../categorization/domain/entities/categoria.dart';
import '../../data/providers/transacciones_repository_provider.dart';
import '../../domain/entities/transaccion_registro.dart';

part 'transacciones_filtro_provider.g.dart';

class TransaccionesFiltro {
  const TransaccionesFiltro({
    this.desde,
    this.hasta,
    this.categoriaId,
    this.tarjetaId,
    this.esRangoPorDefecto = false,
  });

  final DateTime? desde;
  final DateTime? hasta;
  final int? categoriaId;
  final int? tarjetaId;

  /// `true` solo para el rango "mes actual" que trae `build()` al
  /// abrir la pantalla — no es algo que el usuario haya elegido, así
  /// que no debe contar como filtro "activo" para distinguir "de
  /// verdad no hay transacciones" de "no coincide con lo que filtré".
  final bool esRangoPorDefecto;

  bool get tieneFiltrosActivos =>
      desde != null || hasta != null || categoriaId != null || tarjetaId != null;

  /// Filtro elegido a propósito por el usuario (categoría, tarjeta, o
  /// un rango de fechas que él mismo escogió) — a diferencia de
  /// `tieneFiltrosActivos`, ignora el rango "mes actual" por defecto.
  bool get esFiltroExplicito =>
      categoriaId != null ||
      tarjetaId != null ||
      ((desde != null || hasta != null) && !esRangoPorDefecto);
}

/// Estado de los filtros de la lista de transacciones (sección 9.4 de
/// CLAUDE.md — filtrable por fecha, categoría, tarjeta).
///
/// `keepAlive: true`: otras pantallas (ej. tocar una tarjeta) cambian
/// este filtro sin que la pantalla de Transacciones esté montada para
/// "escucharlo" — sin esto, Riverpod lo descarta (autoDispose, sin
/// listeners activos) antes de que Transacciones llegue a leerlo.
@Riverpod(keepAlive: true)
class TransaccionesFiltroController extends _$TransaccionesFiltroController {
  @override
  TransaccionesFiltro build() {
    // Por defecto, el mes actual — el gasto reciente es lo que más le
    // importa ver al usuario al abrir la lista, no todo el historial.
    // El usuario puede limpiar el filtro para ver todo.
    final ahora = DateTime.now();
    return TransaccionesFiltro(
      desde: DateTime(ahora.year, ahora.month),
      esRangoPorDefecto: true,
    );
  }

  void establecerCategoria(int? categoriaId) {
    state = TransaccionesFiltro(
      desde: state.desde,
      hasta: state.hasta,
      categoriaId: categoriaId,
      tarjetaId: state.tarjetaId,
    );
  }

  void establecerTarjeta(int? tarjetaId) {
    state = TransaccionesFiltro(
      desde: state.desde,
      hasta: state.hasta,
      categoriaId: state.categoriaId,
      tarjetaId: tarjetaId,
    );
  }

  void establecerRangoFechas(DateTime? desde, DateTime? hasta) {
    state = TransaccionesFiltro(
      desde: desde,
      // `showDateRangePicker` devuelve `hasta` a medianoche (solo
      // fecha, sin hora) — si se compara tal cual contra `fecha`
      // (que sí tiene hora real, tomada del correo del banco), las
      // transacciones del último día después de las 00:00 quedarían
      // fuera. Se sube al final del día para incluirlo completo.
      hasta: hasta == null
          ? null
          : DateTime(hasta.year, hasta.month, hasta.day, 23, 59, 59, 999),
      categoriaId: state.categoriaId,
      tarjetaId: state.tarjetaId,
    );
  }

  void limpiar() => state = const TransaccionesFiltro();
}

@riverpod
Future<List<TransaccionRegistro>> transaccionesFiltradas(Ref ref) async {
  final filtro = ref.watch(transaccionesFiltroControllerProvider);
  final repo = await ref.watch(transaccionesRepositoryProvider.future);
  return repo.obtener(
    desde: filtro.desde,
    hasta: filtro.hasta,
    categoriaId: filtro.categoriaId,
    tarjetaId: filtro.tarjetaId,
  );
}

@riverpod
Future<List<Tarjeta>> tarjetasDisponibles(Ref ref) async {
  final repo = await ref.watch(tarjetasRepositoryProvider.future);
  return repo.obtenerTodas();
}

/// Solo las categorías de gasto (sección 8 de CLAUDE.md) — el filtro
/// de la lista de transacciones no ofrece las de ingreso (Nómina,
/// Transferencia, Otro ingreso) como opción.
@riverpod
Future<List<Categoria>> categoriasGasto(Ref ref) async {
  final todas = await ref.watch(todasLasCategoriasProvider.future);
  return [
    for (final categoria in todas)
      if (categoria.tipo == TipoTransaccion.gasto) categoria,
  ];
}

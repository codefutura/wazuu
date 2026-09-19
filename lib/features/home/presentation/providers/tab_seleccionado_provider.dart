import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tab_seleccionado_provider.g.dart';

/// Pestaña activa de `MainShellScreen` — vive en un provider (no en
/// `State` local) para que otras pantallas puedan saltar a una
/// pestaña específica, ej. tocar una tarjeta salta a Transacciones ya
/// filtrada por esa tarjeta.
@riverpod
class TabSeleccionadoController extends _$TabSeleccionadoController {
  @override
  int build() => 0;

  void establecer(int index) => state = index;
}

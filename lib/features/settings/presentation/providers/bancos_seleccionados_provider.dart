import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../banks/data/providers/banks_repository_provider.dart';

part 'bancos_seleccionados_provider.g.dart';

/// Selección de bancos conectados en edición (Ajustes, sección 9.6 de
/// CLAUDE.md) — separado del guardado real para poder mostrar los
/// cambios antes de confirmarlos.
@riverpod
class BancosSeleccionadosController extends _$BancosSeleccionadosController {
  @override
  Future<Set<String>> build() async {
    final repo = await ref.watch(banksRepositoryProvider.future);
    return repo.connectedBankIds();
  }

  void alternar(String bankId) {
    final actual = state.value ?? const <String>{};
    final nuevo = Set<String>.from(actual);
    if (!nuevo.remove(bankId)) nuevo.add(bankId);
    state = AsyncData(nuevo);
  }

  Future<void> guardar() async {
    final repo = await ref.read(banksRepositoryProvider.future);
    await repo.saveConnectedBanks(state.value ?? const <String>{});
  }
}

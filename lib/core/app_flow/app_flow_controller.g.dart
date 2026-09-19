// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_flow_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Orquesta a qué pantalla debe ir el usuario al abrir la app,
/// combinando la cuenta local (Auth) con el progreso del onboarding.
///
/// La sesión es persistente entre arranques (Keychain/Keystore, ver
/// `SessionSecureDataSource`): una vez que el usuario entra con su
/// contraseña, la app vuelve a abrir directo en el Resumen hasta que
/// cierre sesión explícitamente — no vuelve a pedir la contraseña en
/// cada arranque en frío.

@ProviderFor(AppFlowController)
final appFlowControllerProvider = AppFlowControllerProvider._();

/// Orquesta a qué pantalla debe ir el usuario al abrir la app,
/// combinando la cuenta local (Auth) con el progreso del onboarding.
///
/// La sesión es persistente entre arranques (Keychain/Keystore, ver
/// `SessionSecureDataSource`): una vez que el usuario entra con su
/// contraseña, la app vuelve a abrir directo en el Resumen hasta que
/// cierre sesión explícitamente — no vuelve a pedir la contraseña en
/// cada arranque en frío.
final class AppFlowControllerProvider
    extends $AsyncNotifierProvider<AppFlowController, AppFlowState> {
  /// Orquesta a qué pantalla debe ir el usuario al abrir la app,
  /// combinando la cuenta local (Auth) con el progreso del onboarding.
  ///
  /// La sesión es persistente entre arranques (Keychain/Keystore, ver
  /// `SessionSecureDataSource`): una vez que el usuario entra con su
  /// contraseña, la app vuelve a abrir directo en el Resumen hasta que
  /// cierre sesión explícitamente — no vuelve a pedir la contraseña en
  /// cada arranque en frío.
  AppFlowControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appFlowControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appFlowControllerHash();

  @$internal
  @override
  AppFlowController create() => AppFlowController();
}

String _$appFlowControllerHash() => r'696f1bc571f219b88d88d31dd1b088ca96b299f3';

/// Orquesta a qué pantalla debe ir el usuario al abrir la app,
/// combinando la cuenta local (Auth) con el progreso del onboarding.
///
/// La sesión es persistente entre arranques (Keychain/Keystore, ver
/// `SessionSecureDataSource`): una vez que el usuario entra con su
/// contraseña, la app vuelve a abrir directo en el Resumen hasta que
/// cierre sesión explícitamente — no vuelve a pedir la contraseña en
/// cada arranque en frío.

abstract class _$AppFlowController extends $AsyncNotifier<AppFlowState> {
  FutureOr<AppFlowState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AppFlowState>, AppFlowState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AppFlowState>, AppFlowState>,
              AsyncValue<AppFlowState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

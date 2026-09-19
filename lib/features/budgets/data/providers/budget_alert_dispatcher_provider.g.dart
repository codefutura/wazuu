// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_alert_dispatcher_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(budgetAlertDispatcher)
final budgetAlertDispatcherProvider = BudgetAlertDispatcherProvider._();

final class BudgetAlertDispatcherProvider
    extends
        $FunctionalProvider<
          AsyncValue<BudgetAlertDispatcher>,
          BudgetAlertDispatcher,
          FutureOr<BudgetAlertDispatcher>
        >
    with
        $FutureModifier<BudgetAlertDispatcher>,
        $FutureProvider<BudgetAlertDispatcher> {
  BudgetAlertDispatcherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetAlertDispatcherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetAlertDispatcherHash();

  @$internal
  @override
  $FutureProviderElement<BudgetAlertDispatcher> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BudgetAlertDispatcher> create(Ref ref) {
    return budgetAlertDispatcher(ref);
  }
}

String _$budgetAlertDispatcherHash() =>
    r'121818772415912d06dcc32074e2af375f7e20ea';

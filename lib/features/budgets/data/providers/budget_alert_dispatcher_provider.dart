import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/storage/shared_preferences_provider.dart';
import '../datasources/budget_alert_state_data_source.dart';
import '../services/budget_alert_dispatcher.dart';
import '../services/budget_notification_service.dart';

part 'budget_alert_dispatcher_provider.g.dart';

@Riverpod(keepAlive: true)
Future<BudgetAlertDispatcher> budgetAlertDispatcher(Ref ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return BudgetAlertDispatcher(
    BudgetAlertStateDataSource(prefs),
    BudgetNotificationService(),
  );
}

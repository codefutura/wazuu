import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/storage/shared_preferences_provider.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_data_source.dart';
import '../repositories/onboarding_repository_impl.dart';

part 'onboarding_repository_provider.g.dart';

@Riverpod(keepAlive: true)
Future<OnboardingRepository> onboardingRepository(Ref ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return OnboardingRepositoryImpl(OnboardingLocalDataSource(prefs));
}

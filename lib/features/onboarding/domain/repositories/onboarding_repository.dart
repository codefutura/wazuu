import '../entities/onboarding_progress.dart';

abstract interface class OnboardingRepository {
  Future<OnboardingProgress> load();

  Future<void> save(OnboardingProgress progress);

  Future<void> clear();
}

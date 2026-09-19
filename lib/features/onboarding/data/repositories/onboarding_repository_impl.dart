import '../../domain/entities/onboarding_progress.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_data_source.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl(this._dataSource);

  final OnboardingLocalDataSource _dataSource;

  @override
  Future<OnboardingProgress> load() async => _dataSource.read();

  @override
  Future<void> save(OnboardingProgress progress) => _dataSource.write(progress);

  @override
  Future<void> clear() => _dataSource.clear();
}

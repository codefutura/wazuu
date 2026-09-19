import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/storage/secure_storage_provider.dart';
import '../../domain/repositories/gmail_auth_repository.dart';
import '../datasources/gmail_auth_secure_data_source.dart';
import '../repositories/gmail_auth_repository_impl.dart';
import '../services/google_sign_in_service.dart';

part 'gmail_auth_repository_provider.g.dart';

@Riverpod(keepAlive: true)
GmailAuthRepository gmailAuthRepository(Ref ref) {
  final storage = ref.watch(secureStorageProvider);
  return GmailAuthRepositoryImpl(
    GmailAuthSecureDataSource(storage),
    GoogleSignInService(),
  );
}

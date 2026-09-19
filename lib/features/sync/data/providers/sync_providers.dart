import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/storage/shared_preferences_provider.dart';
import '../../../bank_parsers/data/parsers/default_bank_email_parser_registry.dart';
import '../../../banks/data/providers/banks_repository_provider.dart';
import '../../../cards/data/providers/tarjetas_repository_provider.dart';
import '../../../categorization/data/providers/categorization_providers.dart';
import '../../../gmail/data/providers/gmail_auth_repository_provider.dart';
import '../../../transactions/data/providers/transacciones_repository_provider.dart';
import '../../domain/gmail_sync_service.dart';
import '../../domain/repositories/gmail_messages_fetcher.dart';
import '../../domain/repositories/sync_state_repository.dart';
import '../datasources/gmail_messages_data_source.dart';
import '../datasources/sync_state_data_source.dart';
import '../repositories/sync_state_repository_impl.dart';

part 'sync_providers.g.dart';

@Riverpod(keepAlive: true)
GmailMessagesFetcher gmailMessagesFetcher(Ref ref) {
  return const GmailMessagesDataSource();
}

@Riverpod(keepAlive: true)
Future<SyncStateRepository> syncStateRepository(Ref ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return SyncStateRepositoryImpl(SyncStateDataSource(prefs));
}

@Riverpod(keepAlive: true)
Future<GmailSyncService> gmailSyncService(Ref ref) async {
  return GmailSyncService(
    gmailAuthRepository: ref.watch(gmailAuthRepositoryProvider),
    messagesFetcher: ref.watch(gmailMessagesFetcherProvider),
    banksRepository: await ref.watch(banksRepositoryProvider.future),
    tarjetasRepository: await ref.watch(tarjetasRepositoryProvider.future),
    categorizationEngine: await ref.watch(categorizationEngineProvider.future),
    transaccionesRepository: await ref.watch(
      transaccionesRepositoryProvider.future,
    ),
    syncStateRepository: await ref.watch(syncStateRepositoryProvider.future),
    parserRegistry: defaultBankEmailParserRegistry,
  );
}

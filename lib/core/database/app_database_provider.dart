import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import 'app_database.dart';
import 'db_encryption_key_provider.dart';

part 'app_database_provider.g.dart';

@Riverpod(keepAlive: true)
Future<Database> appDatabase(Ref ref) async {
  final passphrase = await ref.watch(dbEncryptionKeyProvider.future);
  return AppDatabase.open(passphrase);
}

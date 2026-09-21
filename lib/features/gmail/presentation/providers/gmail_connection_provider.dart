import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/gmail_auth_repository_provider.dart';
import '../../domain/entities/gmail_connection.dart';

part 'gmail_connection_provider.g.dart';

/// Conexión de Gmail guardada, para mostrar el estado en Ajustes
/// (sección 9.6 de CLAUDE.md). Se invalida manualmente después de
/// conectar/desconectar — ver `GmailConnectionSection`.
@riverpod
Future<GmailConnection?> gmailConnection(Ref ref) {
  return ref.watch(gmailAuthRepositoryProvider).currentConnection();
}

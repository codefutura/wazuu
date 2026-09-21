import 'dart:convert';

import 'package:googleapis/gmail/v1.dart' as gmail;

import '../../../bank_parsers/domain/entities/raw_email.dart';
import '../../../gmail/data/services/authenticated_http_client.dart';
import '../../domain/exceptions/gmail_quota_exceeded_exception.dart';
import '../../domain/repositories/gmail_messages_fetcher.dart';

/// Trae y decodifica correos reales desde la Gmail API.
///
/// La API entrega el cuerpo en base64url dentro de un árbol de
/// `MessagePart` (correos multipart anidan `text/plain`/`text/html`
/// bajo `parts`) — aquí se camina ese árbol una sola vez para dejarle
/// a los parsers (Fase 5) texto plano, nunca el envoltorio MIME.
class GmailMessagesDataSource implements GmailMessagesFetcher {
  const GmailMessagesDataSource();

  @override
  Future<List<String>> listarIds({
    required String accessToken,
    required List<String> remitentes,
    DateTime? despues,
  }) async {
    final client = AuthenticatedHttpClient(accessToken);
    try {
      final api = gmail.GmailApi(client);
      var query = '(${remitentes.map((r) => 'from:$r').join(' OR ')})';
      if (despues != null) {
        // Un día antes por seguridad: `after:` de Gmail es por día
        // completo, no por hora exacta.
        final margen = despues.subtract(const Duration(days: 1));
        query += ' after:${_formatearFecha(margen)}';
      }

      final respuesta = await api.users.messages.list('me', q: query);
      return [
        for (final mensaje in respuesta.messages ?? const <gmail.Message>[])
          if (mensaje.id != null) mensaje.id!,
      ];
    } on gmail.DetailedApiRequestError catch (e) {
      if (_esErrorDeCuota(e)) throw const GmailQuotaExceededException();
      rethrow;
    } finally {
      client.close();
    }
  }

  @override
  Future<RawEmail> obtenerCorreo({
    required String accessToken,
    required String messageId,
  }) async {
    final client = AuthenticatedHttpClient(accessToken);
    try {
      final api = gmail.GmailApi(client);
      final mensaje = await api.users.messages.get(
        'me',
        messageId,
        format: 'full',
      );

      final cuerpo = _CuerpoDecodificado();
      _extraerCuerpo(mensaje.payload, cuerpo);

      return RawEmail(
        id: messageId,
        from: _buscarHeader(mensaje.payload?.headers, 'From') ?? '',
        subject: _buscarHeader(mensaje.payload?.headers, 'Subject') ?? '',
        plainTextBody: cuerpo.plainText,
        htmlBody: cuerpo.html,
      );
    } on gmail.DetailedApiRequestError catch (e) {
      if (_esErrorDeCuota(e)) throw const GmailQuotaExceededException();
      rethrow;
    } finally {
      client.close();
    }
  }

  /// Gmail devuelve 429, o a veces 403 con "Quota exceeded" en el
  /// mensaje, cuando se supera el límite de unidades por minuto.
  bool _esErrorDeCuota(gmail.DetailedApiRequestError e) {
    if (e.status == 429) return true;
    return e.status == 403 &&
        (e.message?.toLowerCase().contains('quota exceeded') ?? false);
  }

  void _extraerCuerpo(gmail.MessagePart? part, _CuerpoDecodificado acc) {
    if (part == null) return;

    final data = part.body?.data;
    if (data != null && data.isNotEmpty) {
      if (part.mimeType == 'text/plain' && acc.plainText == null) {
        acc.plainText = _decodificarBase64Url(data);
      } else if (part.mimeType == 'text/html' && acc.html == null) {
        acc.html = _decodificarBase64Url(data);
      }
    }

    for (final sub in part.parts ?? const <gmail.MessagePart>[]) {
      _extraerCuerpo(sub, acc);
    }
  }

  String _decodificarBase64Url(String data) {
    return utf8.decode(base64Url.decode(base64Url.normalize(data)));
  }

  String? _buscarHeader(
    List<gmail.MessagePartHeader>? headers,
    String nombre,
  ) {
    if (headers == null) return null;
    for (final header in headers) {
      if (header.name?.toLowerCase() == nombre.toLowerCase()) {
        return header.value;
      }
    }
    return null;
  }

  String _formatearFecha(DateTime fecha) {
    final anio = fecha.year.toString().padLeft(4, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final dia = fecha.day.toString().padLeft(2, '0');
    return '$anio/$mes/$dia';
  }
}

class _CuerpoDecodificado {
  String? plainText;
  String? html;
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wazuu/features/bank_parsers/data/parsers/default_bank_email_parser_registry.dart';
import 'package:wazuu/features/bank_parsers/domain/entities/raw_email.dart';

void main() {
  test('reconoce un correo de Popular y marca el bankOptionId correcto', () {
    final fixture = File(
      'test/fixtures/bank_emails/popular_gasto.txt',
    ).readAsStringSync();
    final match = defaultBankEmailParserRegistry.parse(
      RawEmail(
        id: 'msg-1',
        from: 'notificaciones@popularenlinea.com',
        subject: 'Notificación de Consumo',
        plainTextBody: fixture,
      ),
    );

    expect(match, isNotNull);
    expect(match!.bankOptionId, 'popular');
    expect(match.transaccion.comercio, 'CFN FERRECENTRO');
  });

  test('reconoce un correo de BHD y marca el bankOptionId correcto', () {
    final fixture = File(
      'test/fixtures/bank_emails/bhd_gasto.html',
    ).readAsStringSync();
    final match = defaultBankEmailParserRegistry.parse(
      RawEmail(
        id: 'msg-2',
        from: 'Alertas@bhd.com.do',
        subject: 'BHD Notificación de Transacciones',
        htmlBody: fixture,
      ),
    );

    expect(match, isNotNull);
    expect(match!.bankOptionId, 'bhd');
    expect(match.transaccion.comercio, 'FACEBK *ARQPC7AZK4');
  });

  test('devuelve null si ningún parser reconoce el correo', () {
    final match = defaultBankEmailParserRegistry.parse(
      const RawEmail(
        id: 'msg-3',
        from: 'alguien@otrobanco.com',
        subject: 'Sin relación',
        plainTextBody: 'Contenido irrelevante',
      ),
    );

    expect(match, isNull);
  });
}

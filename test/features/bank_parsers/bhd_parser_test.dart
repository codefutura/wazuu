import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wazuu/core/domain/estado_transaccion.dart';
import 'package:wazuu/core/domain/moneda.dart';
import 'package:wazuu/core/domain/tipo_transaccion.dart';
import 'package:wazuu/features/bank_parsers/data/parsers/bhd_parser.dart';
import 'package:wazuu/features/bank_parsers/domain/entities/raw_email.dart';

void main() {
  final parser = const BhdParser();
  final fixture = File(
    'test/fixtures/bank_emails/bhd_gasto.html',
  ).readAsStringSync();

  RawEmail email({String? body, String from = 'Alertas@bhd.com.do'}) {
    return RawEmail(
      id: 'msg-bhd-1',
      from: from,
      subject: 'BHD Notificación de Transacciones',
      htmlBody: body ?? fixture,
    );
  }

  test('parsea un correo real de transacción de BHD en dólares', () {
    final transaccion = parser.parse(email());

    expect(transaccion, isNotNull);
    expect(transaccion!.monto, 2.00);
    expect(transaccion.moneda, Moneda.usd);
    expect(transaccion.fecha, DateTime(2026, 9, 16, 8, 49));
    expect(transaccion.comercio, 'FACEBK *ARQPC7AZK4');
    expect(transaccion.estado, EstadoTransaccion.aprobada);
    expect(transaccion.tipoTransaccion, TipoTransaccion.gasto);
    expect(transaccion.emailIdOrigen, 'msg-bhd-1');
    expect(transaccion.tarjetaUltimos4Digitos, '5472');
  });

  test('parsea un correo real de transacción de BHD en pesos (RD)', () {
    final fixtureRd = File(
      'test/fixtures/bank_emails/bhd_gasto_rd.html',
    ).readAsStringSync();
    final transaccion = parser.parse(email(body: fixtureRd));

    expect(transaccion, isNotNull);
    expect(transaccion!.monto, 1300.00);
    expect(transaccion.moneda, Moneda.dop);
    expect(transaccion.fecha, DateTime(2026, 9, 4, 20, 17));
    expect(transaccion.comercio, 'CASA YANG GUANG');
    expect(transaccion.estado, EstadoTransaccion.aprobada);
    expect(transaccion.tipoTransaccion, TipoTransaccion.gasto);
    expect(transaccion.tarjetaUltimos4Digitos, '5472');
  });

  test(
    'parsea un correo real de transferencia/pago a un beneficiario',
    () {
      final fixtureTransferencia = File(
        'test/fixtures/bank_emails/bhd_transferencia.html',
      ).readAsStringSync();
      final transaccion = parser.parse(email(body: fixtureTransferencia));

      expect(transaccion, isNotNull);
      expect(transaccion!.monto, 6420.00);
      expect(transaccion.moneda, Moneda.dop);
      expect(transaccion.fecha, DateTime(2026, 9, 22, 10, 13));
      expect(transaccion.comercio, 'COMERCIO EJEMPLO SRL');
      expect(transaccion.estado, EstadoTransaccion.aprobada);
      expect(transaccion.tipoTransaccion, TipoTransaccion.gasto);
      expect(transaccion.tarjetaUltimos4Digitos, isNull);
      expect(transaccion.categoriaSugerida, 'Finanzas');
    },
  );

  test(
    'devuelve null ante un tipo de transacción que no reconoce todavía',
    () {
      final fixtureTransferencia = File(
        'test/fixtures/bank_emails/bhd_transferencia.html',
      ).readAsStringSync();
      final otroTipo = fixtureTransferencia.replaceFirst(
        'Transacciones entre productos BHD y a otros Bancos',
        'Otro tipo de transacción no confirmado',
      );
      final result = parser.parse(email(body: otroTipo));
      expect(result, isNull);
    },
  );

  test('ignora correos de un remitente que no es BHD', () {
    final result = parser.parse(email(from: 'notificaciones@otrobanco.com'));
    expect(result, isNull);
  });

  test('devuelve null si no hay cuerpo HTML', () {
    final result = parser.parse(
      RawEmail(
        id: 'msg-bhd-2',
        from: 'Alertas@bhd.com.do',
        subject: 'BHD Notificación de Transacciones',
      ),
    );
    expect(result, isNull);
  });

  test('devuelve null ante un código de moneda no confirmado (ej. EUR)', () {
    final unconfirmed = fixture.replaceFirst(
      '''
                  US
                ''',
      '''
                  EUR
                ''',
    );
    final result = parser.parse(email(body: unconfirmed));
    expect(result, isNull);
  });

  test('devuelve null ante una plantilla que no reconoce', () {
    final result = parser.parse(email(body: '<html><body>Sin tabla</body></html>'));
    expect(result, isNull);
  });
}

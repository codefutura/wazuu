import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wazuu/core/domain/estado_transaccion.dart';
import 'package:wazuu/core/domain/moneda.dart';
import 'package:wazuu/core/domain/tipo_transaccion.dart';
import 'package:wazuu/features/bank_parsers/data/parsers/banreservas_parser.dart';
import 'package:wazuu/features/bank_parsers/domain/entities/raw_email.dart';

void main() {
  final parser = const BanreservasParser();
  final fixture = File(
    'test/fixtures/bank_emails/banreservas_ingreso.html',
  ).readAsStringSync();

  RawEmail email({
    String? body,
    String from = 'NotificacionesTuBancoApp@banreservas.com',
  }) {
    return RawEmail(
      id: 'msg-banreservas-1',
      from: from,
      subject: 'Recibo de la transacción',
      htmlBody: body ?? fixture,
    );
  }

  test(
    'parsea un correo real de transferencia recibida de Banreservas',
    () {
      final transaccion = parser.parse(email());

      expect(transaccion, isNotNull);
      expect(transaccion!.monto, 4340.00);
      expect(transaccion.moneda, Moneda.dop);
      expect(transaccion.fecha, DateTime(2026, 4, 11, 14, 24));
      expect(transaccion.comercio, 'JUANA PEREZ DE LA CRUZ');
      expect(transaccion.estado, EstadoTransaccion.aprobada);
      expect(transaccion.tipoTransaccion, TipoTransaccion.ingreso);
      expect(transaccion.emailIdOrigen, 'msg-banreservas-1');
      expect(transaccion.tarjetaUltimos4Digitos, isNull);
    },
  );

  test('ignora correos de un remitente que no es Banreservas', () {
    final result = parser.parse(email(from: 'notificaciones@otrobanco.com'));
    expect(result, isNull);
  });

  test('devuelve null si no hay cuerpo HTML', () {
    final result = parser.parse(
      RawEmail(
        id: 'msg-banreservas-2',
        from: 'NotificacionesTuBancoApp@banreservas.com',
        subject: 'Recibo de la transacción',
      ),
    );
    expect(result, isNull);
  });

  test(
    'devuelve null ante un tipo de transacción que no reconoce todavía',
    () {
      final otraTransaccion = fixture.replaceFirst(
        'Transferencia a Tercero',
        'Pago de Tarjeta de Crédito',
      );
      final result = parser.parse(email(body: otraTransaccion));
      expect(result, isNull);
    },
  );

  test('devuelve null ante una plantilla que no reconoce', () {
    final result = parser.parse(
      email(body: '<html><body>Sin tabla de detalles</body></html>'),
    );
    expect(result, isNull);
  });
}

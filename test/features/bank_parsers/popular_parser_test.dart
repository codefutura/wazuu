import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wazuu/core/domain/estado_transaccion.dart';
import 'package:wazuu/core/domain/moneda.dart';
import 'package:wazuu/core/domain/tipo_transaccion.dart';
import 'package:wazuu/features/bank_parsers/data/parsers/popular_parser.dart';
import 'package:wazuu/features/bank_parsers/domain/entities/raw_email.dart';

void main() {
  final parser = const PopularParser();
  final fixture = File(
    'test/fixtures/bank_emails/popular_gasto.txt',
  ).readAsStringSync();

  RawEmail email({String? body, String from = 'notificaciones@popularenlinea.com'}) {
    return RawEmail(
      id: 'msg-popular-1',
      from: from,
      subject: 'Notificación de Consumo',
      plainTextBody: body ?? fixture,
    );
  }

  test('parsea un correo real de consumo de Popular', () {
    final transaccion = parser.parse(email());

    expect(transaccion, isNotNull);
    expect(transaccion!.monto, 185.14);
    expect(transaccion.moneda, Moneda.dop);
    expect(transaccion.fecha, DateTime(2026, 9, 15));
    expect(transaccion.comercio, 'CFN FERRECENTRO');
    expect(transaccion.estado, EstadoTransaccion.aprobada);
    expect(transaccion.tipoTransaccion, TipoTransaccion.gasto);
    expect(transaccion.emailIdOrigen, 'msg-popular-1');
    expect(transaccion.tarjetaUltimos4Digitos, '2319');
  });

  test('ignora correos de un remitente que no es Popular', () {
    final result = parser.parse(email(from: 'notificaciones@otrobanco.com'));
    expect(result, isNull);
  });

  test('devuelve null si no hay cuerpo en texto plano', () {
    final result = parser.parse(
      RawEmail(
        id: 'msg-popular-2',
        from: 'notificaciones@popularenlinea.com',
        subject: 'Notificación de Consumo',
      ),
    );
    expect(result, isNull);
  });

  test('devuelve null ante una plantilla que no reconoce', () {
    final result = parser.parse(email(body: 'Contenido irreconocible'));
    expect(result, isNull);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:wazuu/features/settings/data/datasources/bcrd_exchange_rate_data_source.dart';
import 'package:wazuu/features/settings/domain/entities/tasa_bcrd.dart';

void main() {
  // Respuesta real capturada de bancentral.gov.do/Home/GetActualExchangeRate
  // (verificada manualmente, sección 9.6 de CLAUDE.md — no se adivina el
  // formato).
  const respuestaReal = '''
  {
    "result": {
      "actualPurchaseValue": 58.9582,
      "actualPurchaseInteranualValue": 4.4777,
      "actualPurchaseAccumulatedValue": 6.682,
      "actualSellingValue": 59.3318,
      "actualSellingInteranualValue": 4.4228,
      "actualSellingAccumulatedValue": 6.694,
      "date": "2026-09-17T00:00:00Z",
      "actualPurchaseInteranualValueFormatted": "4.5",
      "actualPurchaseAccumulatedValueFormatted": "6.7",
      "actualPurchaseValueFormatted": "58.9582",
      "actualSellingInteranualValueFormatted": "4.4",
      "actualSellingAccumulatedValueFormatted": "6.7",
      "actualSellingValueFormatted": "59.3318"
    },
    "targetUrl": null,
    "success": true,
    "error": null,
    "unAuthorizedRequest": false,
    "__abp": true
  }
  ''';

  test('interpreta una respuesta real del Banco Central', () {
    final tasa = BcrdExchangeRateDataSource.parsearTasaActual(respuestaReal);

    expect(tasa.compra, 58.9582);
    expect(tasa.venta, 59.3318);
    expect(tasa.fecha, DateTime.utc(2026, 9, 17));
  });

  test('cuerpo vacío (sin cookies válidas) lanza una excepción legible', () {
    expect(
      () => BcrdExchangeRateDataSource.parsearTasaActual(''),
      throwsA(isA<BcrdExchangeRateException>()),
    );
  });

  test('cuerpo que no es JSON lanza una excepción legible', () {
    expect(
      () => BcrdExchangeRateDataSource.parsearTasaActual('<html>error</html>'),
      throwsA(isA<BcrdExchangeRateException>()),
    );
  });

  test('success:false lanza una excepción legible', () {
    expect(
      () => BcrdExchangeRateDataSource.parsearTasaActual(
        '{"success": false, "result": null}',
      ),
      throwsA(isA<BcrdExchangeRateException>()),
    );
  });

  test('un cambio de formato inesperado lanza una excepción legible', () {
    expect(
      () => BcrdExchangeRateDataSource.parsearTasaActual(
        '{"success": true, "result": {"otroCampo": 1}}',
      ),
      throwsA(isA<BcrdExchangeRateException>()),
    );
  });
}

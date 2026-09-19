import 'dart:convert';
import 'dart:io';

import '../../domain/entities/tasa_bcrd.dart';

/// Trae la tasa de cambio USD/DOP del día directamente del Banco
/// Central (sección 9.6 de CLAUDE.md) — solo alimenta el campo manual
/// de Ajustes, el usuario sigue confirmando y pudiendo editarla antes
/// de guardar.
///
/// El endpoint (`bancentral.gov.do/Home/GetActualExchangeRate`) no es
/// una API pública documentada — es el mismo que usa su propia página
/// de tasas históricas, verificado manualmente pidiéndolo con y sin
/// sesión. Por eso usa `dart:io` directo en vez de `package:http`:
/// hace falta reenviar TODAS las cookies de sesión que entrega el GET
/// inicial (no solo `ASP.NET_SessionId`, sin las demás el POST
/// responde vacío), y `package:http` junta encabezados `Set-Cookie`
/// repetidos con comas, rompiendo su parseo — `dart:io` los expone ya
/// separados en `response.cookies`.
///
/// El sitio manda dos `Set-Cookie` distintos para `wptem` en la misma
/// respuesta (uno vacío, uno con el valor real) — hay que quedarse
/// solo con el último por nombre antes de reenviarlas, como hace un
/// cookie jar real; reenviar ambas hace que el servidor devuelva el
/// cuerpo vacío (confirmado reproduciendo el bug con un script suelto).
class BcrdExchangeRateDataSource {
  const BcrdExchangeRateDataSource();

  static final _paginaUri = Uri.parse(
    'https://www.bancentral.gov.do/SectorExterno/HistoricoTasas',
  );
  static final _tasaUri = Uri.parse(
    'https://www.bancentral.gov.do/Home/GetActualExchangeRate',
  );

  Future<TasaBcrd> obtenerTasaActual() async {
    final client = HttpClient();
    try {
      final paginaRequest = await client.getUrl(_paginaUri);
      final paginaResponse = await paginaRequest.close();
      await paginaResponse.drain<void>();

      // Deduplica por nombre (se queda con el último) — ver la nota de
      // clase sobre el `wptem` duplicado.
      final cookiesUnicas = <String, Cookie>{};
      for (final cookie in paginaResponse.cookies) {
        cookiesUnicas[cookie.name] = cookie;
      }

      final tasaRequest = await client.postUrl(_tasaUri);
      tasaRequest.cookies.addAll(cookiesUnicas.values);
      final tasaResponse = await tasaRequest.close();
      final cuerpo = await tasaResponse.transform(utf8.decoder).join();

      return parsearTasaActual(cuerpo);
    } on BcrdExchangeRateException {
      rethrow;
    } catch (_) {
      throw const BcrdExchangeRateException(
        'No se pudo conectar con el Banco Central. Revisa tu conexión '
        'e ingresa la tasa manualmente.',
      );
    } finally {
      client.close();
    }
  }

  /// Separado de la llamada de red para poder probarlo con una
  /// respuesta real ya capturada, sin depender de internet en los
  /// tests.
  static TasaBcrd parsearTasaActual(String cuerpo) {
    if (cuerpo.isEmpty) {
      throw const BcrdExchangeRateException(
        'El Banco Central no devolvió datos. Intenta de nuevo.',
      );
    }

    final Map<String, dynamic> json;
    try {
      json = jsonDecode(cuerpo) as Map<String, dynamic>;
    } catch (_) {
      throw const BcrdExchangeRateException(
        'La respuesta del Banco Central no se pudo interpretar.',
      );
    }

    if (json['success'] != true || json['result'] is! Map) {
      throw const BcrdExchangeRateException(
        'El Banco Central no devolvió la tasa actual.',
      );
    }

    final result = json['result'] as Map<String, dynamic>;
    final compra = result['actualPurchaseValue'];
    final venta = result['actualSellingValue'];
    final fecha = result['date'];
    if (compra is! num || venta is! num || fecha is! String) {
      throw const BcrdExchangeRateException(
        'El Banco Central cambió el formato de su respuesta.',
      );
    }

    return TasaBcrd(
      compra: compra.toDouble(),
      venta: venta.toDouble(),
      fecha: DateTime.parse(fecha),
    );
  }
}

import '../../../../core/domain/estado_transaccion.dart';
import '../../../../core/domain/moneda.dart';
import '../../../../core/domain/tipo_transaccion.dart';
import '../../domain/entities/raw_email.dart';
import '../../domain/entities/transaccion.dart';
import '../../domain/parsers/bank_email_parser.dart';
import 'parsing_utils.dart';

/// Parser de "Notificación de Consumo" de Banco Popular Dominicano
/// (texto plano). Basado en un correo real (ver
/// `test/fixtures/bank_emails/popular_gasto.txt`), anonimizado.
///
/// Solo reconoce correos de gasto (consumo con tarjeta). Popular
/// también envía notificaciones de ingreso con otra plantilla, pero no
/// tenemos un ejemplo real todavía — hasta entonces, esos correos caen
/// fuera de `_rowRegex` y `parse` devuelve `null` en vez de adivinar.
class PopularParser implements BankEmailParser {
  const PopularParser();

  static final _cardRegex = RegExp(r'terminada en\s+(\d{4})');

  // Grupos: 1=símbolo moneda, 2=monto, 3=nombre moneda (sin usar),
  // 4=fecha, 5=comercio, 6=estatus.
  static final _rowRegex = RegExp(
    r'(RD\$|US\$)\s*([\d,]+\.\d{2})\s+([^\t\n]+?)\s+'
    r'(\d{2}/\d{2}/\d{4})\s+(.+?)\s+(Aprobada|Declinada)',
    dotAll: true,
  );

  @override
  Transaccion? parse(RawEmail email) {
    if (!email.from.toLowerCase().contains('popularenlinea.com')) {
      return null;
    }
    final body = email.plainTextBody;
    if (body == null) return null;

    final rowMatch = _rowRegex.firstMatch(body);
    if (rowMatch == null) return null;

    final symbol = rowMatch.group(1)!;
    final monto = double.tryParse(rowMatch.group(2)!.replaceAll(',', ''));
    final fecha = parseDdMmYyyy(rowMatch.group(4)!);
    if (monto == null || fecha == null) return null;

    return Transaccion(
      monto: monto,
      moneda: symbol == r'RD$' ? Moneda.dop : Moneda.usd,
      fecha: fecha,
      comercio: collapseWhitespace(rowMatch.group(5)!),
      estado: rowMatch.group(6) == 'Aprobada'
          ? EstadoTransaccion.aprobada
          : EstadoTransaccion.declinada,
      tipoTransaccion: TipoTransaccion.gasto,
      emailIdOrigen: email.id,
      tarjetaUltimos4Digitos: _cardRegex.firstMatch(body)?.group(1),
    );
  }
}

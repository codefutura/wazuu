import 'package:html/parser.dart' as html_parser;

import '../../../../core/domain/estado_transaccion.dart';
import '../../../../core/domain/moneda.dart';
import '../../../../core/domain/tipo_transaccion.dart';
import '../../domain/entities/raw_email.dart';
import '../../domain/entities/transaccion.dart';
import '../../domain/parsers/bank_email_parser.dart';
import 'parsing_utils.dart';

/// Parser de "BHD Notificación de Transacciones" (HTML). Basado en
/// correos reales (ver `test/fixtures/bank_emails/bhd_gasto.html` para
/// dólares y `bhd_gasto_rd.html` para pesos).
///
/// Solo reconoce los códigos de moneda `US` (dólar) y `RD` (peso
/// dominicano) en la columna "Moneda" — son los únicos confirmados con
/// un correo real. Cualquier otro código devuelve `null` en vez de
/// adivinar.
///
/// Solo reconoce correos de "Compra" (gasto). No tenemos un ejemplo
/// real de un correo de ingreso de BHD todavía.
class BhdParser implements BankEmailParser {
  const BhdParser();

  static const _monedaPorCodigo = {'US': Moneda.usd, 'RD': Moneda.dop};

  static final _cardRegex = RegExp(r'#\s*(\d{4})\b');
  static final _dateTimeRegex = RegExp(
    r'(\d{2}/\d{2}/\d{4})\s+(\d{1,2}:\d{2}\s*(?:am|pm))',
    caseSensitive: false,
  );

  @override
  Transaccion? parse(RawEmail email) {
    if (!email.from.toLowerCase().contains('bhd.com.do')) return null;
    final htmlBody = email.htmlBody;
    if (htmlBody == null) return null;

    final document = html_parser.parse(htmlBody);
    final row = document.querySelector('table.table_trans tbody tr');
    if (row == null) return null;

    final cells = row
        .querySelectorAll('td')
        .map((td) => collapseWhitespace(td.text))
        .toList();
    // Fecha, Moneda, Monto, Comercio, Estado, Tipo.
    if (cells.length != 6) return null;

    if (cells[5] != 'Compra') return null;
    final estatus = cells[4];
    if (estatus != 'Aprobada' && estatus != 'Declinada') return null;

    final moneda = _monedaPorCodigo[cells[1]];
    if (moneda == null) return null;

    final montoTexto = cells[2].replaceAll(RegExp(r'[^\d.,]'), '');
    final monto = double.tryParse(montoTexto.replaceAll(',', ''));
    if (monto == null) return null;

    final dateMatch = _dateTimeRegex.firstMatch(cells[0]);
    if (dateMatch == null) return null;
    final fecha = parseDdMmYyyy(
      dateMatch.group(1)!,
      time12h: dateMatch.group(2),
    );
    if (fecha == null) return null;

    final bodyText = collapseWhitespace(document.body?.text ?? '');

    return Transaccion(
      monto: monto,
      moneda: moneda,
      fecha: fecha,
      comercio: cells[3],
      estado: estatus == 'Aprobada'
          ? EstadoTransaccion.aprobada
          : EstadoTransaccion.declinada,
      tipoTransaccion: TipoTransaccion.gasto,
      emailIdOrigen: email.id,
      tarjetaUltimos4Digitos: _cardRegex.firstMatch(bodyText)?.group(1),
    );
  }
}

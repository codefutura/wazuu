import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

import '../../../../core/domain/estado_transaccion.dart';
import '../../../../core/domain/moneda.dart';
import '../../../../core/domain/tipo_transaccion.dart';
import '../../domain/entities/raw_email.dart';
import '../../domain/entities/transaccion.dart';
import '../../domain/parsers/bank_email_parser.dart';
import 'parsing_utils.dart';

/// Parser de "BHD Notificación de Transacciones" (HTML). Reconoce dos
/// plantillas distintas de BHD (sección 7 de CLAUDE.md — plantillas
/// distintas dentro del mismo banco):
///
/// - Consumo con tarjeta (`table.table_trans`), basado en correos
///   reales — ver `test/fixtures/bank_emails/bhd_gasto.html` para
///   dólares y `bhd_gasto_rd.html` para pesos. Solo reconoce los
///   códigos de moneda `US` (dólar) y `RD` (peso dominicano) en la
///   columna "Moneda" — los únicos confirmados con un correo real.
/// - Transferencia/pago a un beneficiario (`#idTipoTransaccion`),
///   basado en `test/fixtures/bank_emails/bhd_transferencia.html`.
///   Solo reconoce el valor exacto "Transacciones entre productos BHD
///   y a otros Bancos" en ese campo — cualquier otro tipo devuelve
///   `null` en vez de adivinar.
///
/// Ambas se tratan como gasto. No tenemos un ejemplo real de un
/// correo de ingreso de BHD todavía.
class BhdParser implements BankEmailParser {
  const BhdParser();

  static const _monedaPorCodigo = {'US': Moneda.usd, 'RD': Moneda.dop};
  static const _monedaPorSimbolo = {'US\$': Moneda.usd, 'RD\$': Moneda.dop};

  static final _cardRegex = RegExp(r'#\s*(\d{4})\b');
  static final _dateTimeRegex = RegExp(
    r'(\d{2}/\d{2}/\d{4})\s+(\d{1,2}:\d{2}\s*(?:am|pm))',
    caseSensitive: false,
  );
  static final _dateTimeConGuionRegex = RegExp(
    r'(\d{2}/\d{2}/\d{4})\s*-\s*(\d{1,2}:\d{2}\s*(?:am|pm))',
    caseSensitive: false,
  );
  static final _montoConSimboloRegex = RegExp(r'(US\$|RD\$)\s*([\d,]+\.\d{2})');

  @override
  Transaccion? parse(RawEmail email) {
    if (!email.from.toLowerCase().contains('bhd.com.do')) return null;
    final htmlBody = email.htmlBody;
    if (htmlBody == null) return null;

    final document = html_parser.parse(htmlBody);
    return _parseConsumo(document, email) ?? _parseTransferencia(document, email);
  }

  Transaccion? _parseConsumo(Document document, RawEmail email) {
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

  /// Transferencia/pago desde una cuenta propia a un beneficiario —
  /// no trae un campo de estado explícito (el correo solo se envía
  /// cuando la transacción ya se completó, con su número de
  /// confirmación), así que se asume aprobada.
  Transaccion? _parseTransferencia(Document document, RawEmail email) {
    final tipo = document.querySelector('#idTipoTransaccion')?.text.trim();
    if (tipo != 'Transacciones entre productos BHD y a otros Bancos') {
      return null;
    }

    final beneficiario = document
        .querySelector('#idBeneficiario')
        ?.text.trim();
    if (beneficiario == null || beneficiario.isEmpty) return null;

    final montoTexto = document.querySelector('#idMonto')?.text.trim();
    if (montoTexto == null) return null;
    final montoMatch = _montoConSimboloRegex.firstMatch(montoTexto);
    if (montoMatch == null) return null;
    final moneda = _monedaPorSimbolo[montoMatch.group(1)!];
    if (moneda == null) return null;
    final monto = double.tryParse(montoMatch.group(2)!.replaceAll(',', ''));
    if (monto == null) return null;

    final fechaTexto = document
        .querySelector('#idFechayHoraTransaccion')
        ?.text.trim();
    if (fechaTexto == null) return null;
    final dateMatch = _dateTimeConGuionRegex.firstMatch(fechaTexto);
    if (dateMatch == null) return null;
    final fecha = parseDdMmYyyy(
      dateMatch.group(1)!,
      time12h: dateMatch.group(2),
    );
    if (fecha == null) return null;

    return Transaccion(
      monto: monto,
      moneda: moneda,
      fecha: fecha,
      comercio: collapseWhitespace(beneficiario),
      estado: EstadoTransaccion.aprobada,
      tipoTransaccion: TipoTransaccion.gasto,
      emailIdOrigen: email.id,
      // El "comercio" aquí es el beneficiario de la transferencia —
      // varía en cada correo y nunca va a calzar con una regla de
      // palabra clave, así que se sugiere "Finanzas" en vez de dejar
      // que todo caiga en "Otro".
      categoriaSugerida: 'Finanzas',
    );
  }
}

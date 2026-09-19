import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

import '../../../../core/domain/estado_transaccion.dart';
import '../../../../core/domain/moneda.dart';
import '../../../../core/domain/tipo_transaccion.dart';
import '../../domain/entities/raw_email.dart';
import '../../domain/entities/transaccion.dart';
import '../../domain/parsers/bank_email_parser.dart';
import 'parsing_utils.dart';

/// Parser de "Comprobante de Pago" de Banreservas (HTML). Basado en un
/// correo real de transferencia recibida (ver
/// `test/fixtures/bank_emails/banreservas_ingreso.html`), anonimizado.
///
/// Solo reconoce el bloque "Transacción: Transferencia a Tercero" —
/// el único ejemplo real que tenemos — como ingreso (transferencia
/// recibida, sección 7 de CLAUDE.md). Cualquier otro valor de
/// "Transacción:" (ej. un consumo con tarjeta, que probablemente use
/// otra plantilla) devuelve `null` en vez de adivinar.
class BanreservasParser implements BankEmailParser {
  const BanreservasParser();

  static const _monedaPorCodigo = {'DOP': Moneda.dop, 'USD': Moneda.usd};

  static final _montoRegex = RegExp(r'(DOP|USD)\s*([\d,]+\.\d{2})');

  @override
  Transaccion? parse(RawEmail email) {
    if (!email.from.toLowerCase().contains('banreservas.com')) return null;
    final htmlBody = email.htmlBody;
    if (htmlBody == null) return null;

    final document = html_parser.parse(htmlBody);

    final titulo = document.querySelector('.message_title')?.text.trim();
    if (titulo != '¡Transacción realizada!') return null;

    final detalles = _leerDetalles(document);
    if (detalles['Transacción'] != 'Transferencia a Tercero') return null;

    final origen = detalles['Origen'];
    final fechaTexto = detalles['Fecha de transacción'];
    if (origen == null || fechaTexto == null) return null;

    final fecha = parseFechaLargaEsp(fechaTexto);
    if (fecha == null) return null;

    final montoTexto = document.querySelector('.amount_value')?.text.trim();
    if (montoTexto == null) return null;
    final montoMatch = _montoRegex.firstMatch(montoTexto);
    if (montoMatch == null) return null;

    final moneda = _monedaPorCodigo[montoMatch.group(1)!];
    if (moneda == null) return null;
    final monto = double.tryParse(
      montoMatch.group(2)!.replaceAll(',', ''),
    );
    if (monto == null) return null;

    return Transaccion(
      monto: monto,
      moneda: moneda,
      fecha: fecha,
      // Solo el nombre, sin el detalle de cuenta ("Cuenta de ahorro
      // DOP ** - 1111") que sigue después de la coma.
      comercio: collapseWhitespace(origen.split(',').first),
      estado: EstadoTransaccion.aprobada,
      tipoTransaccion: TipoTransaccion.ingreso,
      emailIdOrigen: email.id,
    );
  }

  /// Cada fila de la tabla de detalles tiene una celda
  /// `details_table_row_title` ("Origen: ") seguida de una
  /// `details_table_row_subtitle` con el valor — se recorren en orden
  /// de documento y se emparejan por posición.
  Map<String, String> _leerDetalles(Document document) {
    final titulos = document.querySelectorAll('.details_table_row_title');
    final subtitulos = document.querySelectorAll(
      '.details_table_row_subtitle',
    );
    final detalles = <String, String>{};
    for (var i = 0; i < titulos.length && i < subtitulos.length; i++) {
      final clave = titulos[i].text.trim().replaceAll(':', '');
      detalles[clave] = collapseWhitespace(subtitulos[i].text);
    }
    return detalles;
  }
}

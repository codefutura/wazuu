import '../entities/raw_email.dart';
import '../entities/transaccion.dart';
import 'bank_email_parser.dart';

/// Resultado de intentar parsear un correo: qué banco lo reconoció
/// (el `BankOption.id` del catálogo) y la transacción extraída.
class BankParserMatch {
  const BankParserMatch({required this.bankOptionId, required this.transaccion});

  final String bankOptionId;
  final Transaccion transaccion;
}

/// Prueba cada parser registrado contra el correo hasta que uno lo
/// reconozca — patrón Adapter (sección 7 de CLAUDE.md). Agregar un
/// banco nuevo es agregar una entrada aquí, no tocar el motor de
/// sincronización.
class BankEmailParserRegistry {
  const BankEmailParserRegistry(this._parsersByBankOptionId);

  final Map<String, BankEmailParser> _parsersByBankOptionId;

  BankParserMatch? parse(RawEmail email) {
    for (final entry in _parsersByBankOptionId.entries) {
      final transaccion = entry.value.parse(email);
      if (transaccion != null) {
        return BankParserMatch(
          bankOptionId: entry.key,
          transaccion: transaccion,
        );
      }
    }
    return null;
  }
}

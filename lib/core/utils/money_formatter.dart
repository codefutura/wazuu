import 'package:intl/intl.dart';

import '../domain/moneda.dart';

/// Formatea montos como los ven los correos bancarios reales
/// (`RD$185.14`, `US$2.00`) — sin depender de datos de locale
/// específicos de RD, que `intl` no trae garantizados.
abstract final class MoneyFormatter {
  static final _numero = NumberFormat('#,##0.00', 'en_US');

  static String format(double monto, Moneda moneda) {
    final simbolo = moneda == Moneda.dop ? r'RD$' : r'US$';
    return '$simbolo${_numero.format(monto)}';
  }
}

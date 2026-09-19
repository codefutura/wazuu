/// Parsea `dd/mm/aaaa` (y opcionalmente `HH:mm am/pm` a continuación),
/// formato de fecha compartido por los correos de Popular y BHD.
DateTime? parseDdMmYyyy(String dateText, {String? time12h}) {
  final parts = dateText.split('/');
  if (parts.length != 3) return null;
  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) return null;

  if (time12h == null) return DateTime(year, month, day);

  final match = RegExp(
    r'^(\d{1,2}):(\d{2})\s*(am|pm)$',
    caseSensitive: false,
  ).firstMatch(time12h.trim());
  if (match == null) return DateTime(year, month, day);

  var hour = int.parse(match.group(1)!);
  final minute = int.parse(match.group(2)!);
  final meridiem = match.group(3)!.toLowerCase();
  if (meridiem == 'pm' && hour != 12) hour += 12;
  if (meridiem == 'am' && hour == 12) hour = 0;

  return DateTime(year, month, day, hour, minute);
}

String collapseWhitespace(String input) =>
    input.replaceAll(RegExp(r'\s+'), ' ').trim();

const _mesesEsp = {
  'enero': 1,
  'febrero': 2,
  'marzo': 3,
  'abril': 4,
  'mayo': 5,
  'junio': 6,
  'julio': 7,
  'agosto': 8,
  'septiembre': 9,
  'octubre': 10,
  'noviembre': 11,
  'diciembre': 12,
};

/// Parsea `d de <mes> aaaa - HH:mm am/pm` (nombre de mes en español),
/// formato usado por los correos de Banreservas — distinto del
/// `dd/mm/aaaa` numérico de Popular/BHD (ver [parseDdMmYyyy]).
DateTime? parseFechaLargaEsp(String texto) {
  final match = RegExp(
    r'(\d{1,2})\s+de\s+(\p{L}+)\s+(\d{4})\s*-\s*(\d{1,2}):(\d{2})\s*(am|pm)',
    caseSensitive: false,
    unicode: true,
  ).firstMatch(texto);
  if (match == null) return null;

  final day = int.parse(match.group(1)!);
  final month = _mesesEsp[match.group(2)!.toLowerCase()];
  if (month == null) return null;
  final year = int.parse(match.group(3)!);

  var hour = int.parse(match.group(4)!);
  final minute = int.parse(match.group(5)!);
  final meridiem = match.group(6)!.toLowerCase();
  if (meridiem == 'pm' && hour != 12) hour += 12;
  if (meridiem == 'am' && hour == 12) hour = 0;

  return DateTime(year, month, day, hour, minute);
}

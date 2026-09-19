import '../../domain/parsers/bank_email_parser_registry.dart';
import 'banreservas_parser.dart';
import 'bhd_parser.dart';
import 'popular_parser.dart';

/// Instancia real de la app — las llaves son los `BankOption.id` del
/// catálogo de `features/banks` (sección 7 de CLAUDE.md).
const defaultBankEmailParserRegistry = BankEmailParserRegistry({
  'popular': PopularParser(),
  'bhd': BhdParser(),
  'banreservas': BanreservasParser(),
});

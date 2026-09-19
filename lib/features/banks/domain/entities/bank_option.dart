/// Banco disponible para monitorear — checklist del onboarding y, más
/// adelante, de Ajustes (sección 9 de CLAUDE.md).
///
/// Mock: en la Fase 5 este catálogo se ajusta a los parsers realmente
/// implementados (sección 7 de CLAUDE.md).
class BankOption {
  const BankOption({
    required this.id,
    required this.name,
    required this.senderEmail,
  });

  final String id;
  final String name;
  final String senderEmail;
}

const supportedBanksCatalog = <BankOption>[
  BankOption(
    id: 'banreservas',
    name: 'Banreservas',
    // Verificado contra un correo real (recibo de transferencia) — el
    // remitente real es "NotificacionesTuBancoApp@", no "alertas@".
    senderEmail: 'notificacionestubancoapp@banreservas.com',
  ),
  BankOption(
    id: 'bhd',
    name: 'BHD',
    // Verificado contra un correo real (Fase 5) — BHD envía desde este
    // remitente exacto, no desde "notificaciones@".
    senderEmail: 'alertas@bhd.com.do',
  ),
  BankOption(
    id: 'popular',
    name: 'Banco Popular Dominicano',
    // Verificado contra un correo real (Fase 5) — el dominio real es
    // "popularenlinea.com", no "popular.com.do" (usado también por
    // `PopularParser` para reconocer el remitente).
    senderEmail: 'notificaciones@popularenlinea.com',
  ),
];

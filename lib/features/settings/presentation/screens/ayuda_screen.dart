import 'package:flutter/material.dart';

/// Ayuda — cómo funciona la app y preguntas frecuentes.
class AyudaScreen extends StatelessWidget {
  const AyudaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Ayuda')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('¿Cómo funciona Wazuu?', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Wazuu lee las notificaciones que tus bancos ya te envían por '
            'correo cuando usas tus tarjetas, y arma tu resumen de gastos '
            'automáticamente. Nunca enviamos, respondemos ni eliminamos '
            'correos: solo leemos.\n\n'
            'La sincronización es manual: toca el ícono de sincronizar '
            'arriba a la derecha cuando quieras traer tus transacciones '
            'más recientes.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Text('Preguntas frecuentes', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          const _Pregunta(
            pregunta: '¿Por qué no veo mis ingresos o depósitos?',
            respuesta:
                'Los bancos suelen notificar solo los retiros y consumos, '
                'no los depósitos. Por eso Wazuu se enfoca en mostrarte tu '
                'gasto, que es el dato confiable que sí llega por correo.',
          ),
          const _Pregunta(
            pregunta: 'Sincronicé pero no aparece una transacción nueva.',
            respuesta:
                'Revisa que el banco de esa transacción esté conectado en '
                'Ajustes. Si el correo llegó hace poco, dale unos segundos '
                'y vuelve a sincronizar.',
          ),
          const _Pregunta(
            pregunta: 'Agregué una tarjeta pero sus transacciones viejas '
                'no aparecen vinculadas.',
            respuesta:
                'Vuelve a tocar sincronizar: la app revisa las '
                'transacciones sin tarjeta asignada y las vincula '
                'automáticamente si encuentra una tarjeta que coincide.',
          ),
          const _Pregunta(
            pregunta: '¿Cómo cambio la categoría de una transacción?',
            respuesta:
                'Tócala en la lista de Transacciones y elige la categoría '
                'correcta. Wazuu recuerda tu elección para ese comercio y '
                'categoriza igual la próxima vez.',
          ),
          const _Pregunta(
            pregunta: '¿Cómo actualizo la tasa de cambio?',
            respuesta:
                'En Ajustes puedes escribirla a mano o tocar "Usar tasa '
                'del Banco Central" para traer la tasa oficial del día.',
          ),
          const _Pregunta(
            pregunta: '¿Mis datos salen de mi teléfono?',
            respuesta:
                'No. Todo se guarda cifrado en tu dispositivo. Wazuu no '
                'tiene servidores propios donde se acumulen tus datos.',
          ),
        ],
      ),
    );
  }
}

class _Pregunta extends StatelessWidget {
  const _Pregunta({required this.pregunta, required this.respuesta});

  final String pregunta;
  final String respuesta;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pregunta,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(respuesta, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

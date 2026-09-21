import 'package:flutter/material.dart';

import '../widgets/bancos_conectados_section.dart';
import '../widgets/gmail_connection_section.dart';
import '../widgets/tarjetas_section.dart';
import '../widgets/tasa_cambio_section.dart';
import '../widgets/tema_selector.dart';

/// Ajustes (sección 9.6 de CLAUDE.md): tema, tasa de cambio, bancos
/// conectados y gestión de tarjetas.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          TemaSelector(),
          SizedBox(height: 16),
          TasaCambioSection(),
          SizedBox(height: 16),
          GmailConnectionSection(),
          SizedBox(height: 16),
          BancosConectadosSection(),
          SizedBox(height: 16),
          TarjetasSection(),
        ],
      ),
    );
  }
}

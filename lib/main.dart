import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_flow/app_gate.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Cifras de dinero y tablas de transacciones — la app se diseñó solo
  // para vertical, nunca se probó el layout en horizontal.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ProviderScope(child: WazuuApp()));
}

class WazuuApp extends ConsumerWidget {
  const WazuuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeControllerProvider).value ?? ThemeMode.system;

    return MaterialApp(
      title: 'Wazuu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      // Toda la app, y el mercado al que apunta (sección "Dominio" de
      // CLAUDE.md), es en español — sin esto, diálogos nativos de
      // Flutter (el selector de rango de fechas, por ejemplo) caían al
      // inglés por defecto ("SAVE" en vez de "Guardar").
      locale: const Locale('es'),
      supportedLocales: const [Locale('es')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AppGate(),
    );
  }
}

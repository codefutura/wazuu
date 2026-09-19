import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_flow/app_gate.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';

void main() {
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
      home: const AppGate(),
    );
  }
}

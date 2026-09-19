import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../storage/shared_preferences_provider.dart';

part 'theme_mode_provider.g.dart';

const _key = 'theme_mode';

/// `ThemeMode.system` por defecto; el usuario puede forzarlo desde
/// Ajustes (sección 3 de CLAUDE.md).
@Riverpod(keepAlive: true)
class ThemeModeController extends _$ThemeModeController {
  @override
  Future<ThemeMode> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    return switch (prefs.getString(_key)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> establecer(ThemeMode modo) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(_key, modo.name);
    state = AsyncData(modo);
  }
}

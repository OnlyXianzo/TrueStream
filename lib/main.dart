import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/shell/screens/app_shell.dart';
import 'providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const TrueStreamApp(),
    ),
  );
}

class TrueStreamApp extends ConsumerWidget {
  const TrueStreamApp({super.key});

  ThemeMode _mapThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp(
      title: 'TrueStream',
      debugShowCheckedModeBanner: false,
      themeMode: _mapThemeMode(settings.themeMode),
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: settings.onboardingCompleted
          ? const AppShell()
          : const OnboardingScreen(),
    );
  }
}

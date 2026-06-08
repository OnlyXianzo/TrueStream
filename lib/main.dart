import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/shell/screens/app_shell.dart';

void main() {
  runApp(const ProviderScope(child: TrueStreamApp()));
}

class TrueStreamApp extends ConsumerWidget {
  const TrueStreamApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'TrueStream',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const AppShell(),
    );
  }
}

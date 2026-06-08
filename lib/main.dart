import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const TrueStreamApp());
}

class TrueStreamApp extends StatelessWidget {
  const TrueStreamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrueStream',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const Scaffold(
        body: Center(
          child: Text('TrueStream'),
        ),
      ),
    );
  }
}

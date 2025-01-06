import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/drawing/presentation/pages/drawing_page.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yapay Zeka ile Çizim',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const DrawingPage(),
    );
  }
}

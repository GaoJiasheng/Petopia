import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ui/yard_home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: PetopiaApp()));
}

/// Petopia 根组件。
class PetopiaApp extends StatelessWidget {
  const PetopiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Petopia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAF3E3),
        fontFamily: null,
      ),
      home: const YardHomeScreen(),
    );
  }
}

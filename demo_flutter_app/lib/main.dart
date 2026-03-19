import 'package:flutter/material.dart';
import 'screens/verification_home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Property Verification',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0055b8)),
        useMaterial3: true,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
            fontSize: 24,
          ),
          headlineSmall: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
            fontSize: 20,
          ),
          bodyMedium: TextStyle(
            color: Color(0xFF666666),
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ),
      home: const VerificationHomeScreen(),
    );
  }
}

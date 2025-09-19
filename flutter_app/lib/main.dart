// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/LoginRegister/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qovo Login',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF0F1F3),
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
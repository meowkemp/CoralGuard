import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const CoralGuardApp());
}

class CoralGuardApp extends StatelessWidget {
  const CoralGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // ✅ removes the DEBUG ribbon
      title: 'CoralGuard',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomePage(),
    );
  }
}
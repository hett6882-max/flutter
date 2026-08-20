import 'package:flutter/material.dart';

void main() {
  runApp(const FlashmasterApp());
}

class FlashmasterApp extends StatelessWidget {
  const FlashmasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text('Flashmaster'),
        ),
      ),
    );
  }
}
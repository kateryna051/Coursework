import 'package:flutter/material.dart';
import 'pages/auth_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Explore Lithuania',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Jua', // Ensure to add Jua font in pubspec.yaml
      ),
      home: AuthPage(),
    );
  }
}

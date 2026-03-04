import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'views/user/main/main_layout_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Tracker',
      theme: AppTheme.lightTheme,
      home: const MainLayoutPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}


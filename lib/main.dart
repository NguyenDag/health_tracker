import 'package:flutter/material.dart';
import 'package:health_tracker/views/user/logs/history_record_page.dart';
import 'package:health_tracker/views/user/logs/input_record_page.dart';
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
      home: const HistoryScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}


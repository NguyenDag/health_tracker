import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:health_tracker/core/network/supabase_config.dart';
import 'package:health_tracker/data/implementations/repositories/health_repository.dart';
import 'package:health_tracker/viewmodels/admin_users_viewmodel.dart';
import 'package:health_tracker/viewmodels/home_viewmodel.dart';
import 'package:health_tracker/viewmodels/stats_viewmodel.dart';
import 'package:health_tracker/views/splash_screen.dart';
import 'core/theme/app_theme.dart';
import 'viewmodels/auth_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const HealthTrackerApp());
}

class HealthTrackerApp extends StatelessWidget {
  const HealthTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(HealthRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => StatsViewModel(HealthRepository()),
        ),
        ChangeNotifierProvider(create: (_) => AdminUsersViewModel()),
      ],
      child: MaterialApp(
        title: 'HealthTracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}

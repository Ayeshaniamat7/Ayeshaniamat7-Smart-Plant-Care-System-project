import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/plant_service.dart';
import 'services/sensor_service.dart';
import 'services/ai_service.dart';
import 'services/pump_control_service.dart';
import 'views/auth/login_screen.dart';
import 'views/dashboard/live_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => PlantService()),
        ChangeNotifierProvider(create: (_) => SensorService()),
        ChangeNotifierProvider(create: (_) => AIService()),
        ChangeNotifierProvider(create: (_) => PumpControlService()),
      ],
      child: const SmartPlantCareApp(),
    ),
  );
}

class SmartPlantCareApp extends StatelessWidget {
  const SmartPlantCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Plant Care System - 100% Final',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        primarySwatch: Colors.green,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    if (authService.isAuthenticated) {
      return const LiveDashboardScreen();
    } else {
      return const LoginScreen();
    }
  }
}
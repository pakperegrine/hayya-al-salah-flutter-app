import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/splash_screen.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'themes/app_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API service
  final apiService = ApiService();
  await apiService.initialize();

  // Initialize Auth service
  final authService = AuthService();
  await authService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeService()),
        ChangeNotifierProvider.value(value: authService),
      ],
      child: const HayyaAlSalahApp(),
    ),
  );
}

class HayyaAlSalahApp extends StatelessWidget {
  const HayyaAlSalahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          title: 'Hayya Al Salah',
          debugShowCheckedModeBanner: false,
          themeMode: themeService.themeMode,
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          home: const SplashScreen(),
        );
      },
    );
  }
}

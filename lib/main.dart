import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/splash_screen.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/settings_service.dart';
import 'services/theme_service.dart';
import 'themes/app_themes.dart';

void main() async {
  // Add error handling for initialization
  runZonedGuarded(() async {
    // Ensure Flutter bindings are initialized safely
    try {
      WidgetsFlutterBinding.ensureInitialized();
    } catch (e) {
      print('Error initializing Flutter bindings: $e');
      // Try to continue with basic app
      runApp(MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('App initialization failed: $e'),
          ),
        ),
      ));
      return;
    }

    try {
      // Initialize API service with error handling
      final apiService = ApiService();
      await apiService.initialize();

      // Initialize Auth service with error handling
      final authService = AuthService();
      await authService.initialize();

      // Initialize Settings service
      final settingsService = SettingsService();
      await settingsService.initialize();

      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => ThemeService()),
            ChangeNotifierProvider.value(value: authService),
            ChangeNotifierProvider.value(value: settingsService),
          ],
          child: const HayyaAlSalahApp(),
        ),
      );
    } catch (e, stackTrace) {
      // Log error and provide fallback app
      print('Initialization error: $e');
      print('Stack trace: $stackTrace');
      runApp(
        MaterialApp(
          title: 'Hayya Al Salah',
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'App initialization failed',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Error: $e',
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }, (error, stackTrace) {
    // Global error handler
    print('Global error: $error');
    print('Global stack trace: $stackTrace');
  });
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
          builder: (context, widget) {
            // Add error boundary
            ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text(
                        'Something went wrong',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          errorDetails.exception.toString(),
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            };
            return widget ?? const SizedBox();
          },
        );
      },
    );
  }
}

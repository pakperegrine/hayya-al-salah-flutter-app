import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/splash_screen.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/settings_service.dart';
import 'services/theme_service.dart';
import 'themes/app_themes.dart';

void main() async {
  // Add comprehensive error handling for initialization
  runZonedGuarded(() async {
    // Ensure Flutter bindings are initialized safely with multiple fallbacks
    try {
      WidgetsFlutterBinding.ensureInitialized();
    } catch (e) {
      print('Error initializing Flutter bindings: $e');
      // Try alternative initialization
      try {
        runApp(MaterialApp(
          title: 'Hayya Al Salah - Recovery Mode',
          home: Scaffold(
            appBar: AppBar(title: Text('App Loading...')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing app...'),
                ],
              ),
            ),
          ),
        ));
        return;
      } catch (e2) {
        print('Critical error - cannot start app: $e2');
        return;
      }
    }

    // Add delays to prevent race conditions
    await Future.delayed(Duration(milliseconds: 100));

    try {
      // Initialize services with individual error handling
      ApiService? apiService;
      AuthService? authService;
      SettingsService? settingsService;
      
      try {
        apiService = ApiService();
        await apiService.initialize();
      } catch (e) {
        print('Warning: API service failed to initialize: $e');
        // Continue without API service
      }

      try {
        authService = AuthService();
        await authService.initialize();
      } catch (e) {
        print('Warning: Auth service failed to initialize: $e');
        // Create fallback auth service
        authService = AuthService();
      }

      try {
        settingsService = SettingsService();
        await settingsService.initialize();
      } catch (e) {
        print('Warning: Settings service failed to initialize: $e');
        // Create fallback settings service
        settingsService = SettingsService();
      }

      // Add delay before starting the app
      await Future.delayed(Duration(milliseconds: 200));

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
      // Log error and provide comprehensive fallback app
      print('Initialization error: $e');
      print('Stack trace: $stackTrace');
      
      // Provide a minimal working app as fallback
      runApp(
        MaterialApp(
          title: 'Hayya Al Salah',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
          home: Scaffold(
            appBar: AppBar(
              title: Text('Hayya Al Salah'),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'App is starting in safe mode',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'The app encountered an issue during startup. Please try restarting the app.',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Attempt to restart the app
                      exit(0);
                    },
                    child: Text('Restart App'),
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

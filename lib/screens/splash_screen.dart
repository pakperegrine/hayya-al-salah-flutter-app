import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../services/theme_service.dart';
import 'main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();

    // Navigate to main screen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainNavigation(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final isDark = themeService.isDarkMode;

        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        const Color(0xFF23514C),
                        const Color(0xFF2E6B5E),
                        const Color(0xFF18413C),
                      ]
                    : [
                        Colors.white,
                        Colors.grey.shade50,
                        Colors.grey.shade100,
                      ],
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: Column(
                                children: [
                                  // Logo
                                  Container(
                                    width: 150,
                                    height: 150,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      'assets/images/logo-new.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),

                                  const SizedBox(height: 40),

                                  // Arabic Text
                                  Text(
                                    'حيّ على الصلاة',
                                    style: GoogleFonts.amiri(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF23514C),
                                    ),
                                  ),

                                  const SizedBox(height: 15),

                                  // English Text
                                  Text(
                                    'Hayya Al Salah',
                                    style: GoogleFonts.inter(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF23514C),
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  // Subtitle
                                  Text(
                                    'Come to Prayer',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 60),

                      // Loading indicator
                      CircularProgressIndicator(
                        color: isDark ? Colors.white : const Color(0xFF23514C),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        'Loading...',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom credits section
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    children: [
                      // Donated by
                      Text(
                        'Donated By',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Imtiaz Kausar Memorial Foundation',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? Colors.white : const Color(0xFF23514C),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Divider
                      Container(
                        width: 200,
                        height: 1,
                        color: isDark ? Colors.white30 : Colors.grey.shade300,
                      ),

                      const SizedBox(height: 20),

                      // Developed by
                      Text(
                        'Developed by',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pak Peregrine Corporation (An IT Company)',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? Colors.white : const Color(0xFF23514C),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

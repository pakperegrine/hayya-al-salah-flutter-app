import 'package:flutter/material.dart';

import '../services/app_localizations.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'manage_screen.dart';
import 'topics_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TopicsScreen(),
    const FavoritesScreen(),
    const ManageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF23514C),
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: localizations.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.library_books_outlined),
              activeIcon: const Icon(Icons.library_books),
              label: localizations.topics,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.favorite_outline),
              activeIcon: const Icon(Icons.favorite),
              label: localizations.favorites,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              activeIcon: const Icon(Icons.settings),
              label: localizations.manage,
            ),
          ],
        ),
      ),
    );
  }
}

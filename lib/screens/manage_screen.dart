import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/theme_service.dart';
import 'privacy_policy_screen.dart';

class ManageScreen extends StatefulWidget {
  const ManageScreen({super.key});

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  bool _notificationsEnabled = true;
  bool _autoPlayEnabled = true;
  bool _downloadOverWifiOnly = true;
  String _selectedLanguage = 'English';
  String _selectedQuality = 'HD';

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              'Manage',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // User Profile Section
                _buildProfileSection(),

                // Settings Sections
                _buildSettingsSection(
                  'Preferences',
                  [
                    _buildSwitchTile(
                      'Notifications',
                      'Receive prayer reminders and lesson updates',
                      Icons.notifications_outlined,
                      _notificationsEnabled,
                      (value) => setState(() => _notificationsEnabled = value),
                    ),
                    _buildSwitchTile(
                      'Dark Mode',
                      'Enable dark theme',
                      Icons.dark_mode_outlined,
                      themeService.isDarkMode,
                      (value) => themeService.toggleTheme(),
                    ),
                    _buildDropdownTile(
                      'Language',
                      'Select app language',
                      Icons.language_outlined,
                      _selectedLanguage,
                      ['English', 'Arabic', 'Urdu'],
                      (value) => setState(() => _selectedLanguage = value!),
                    ),
                  ],
                ),

                _buildSettingsSection(
                  'Video Settings',
                  [
                    _buildSwitchTile(
                      'Auto Play',
                      'Automatically play next lesson',
                      Icons.play_arrow_outlined,
                      _autoPlayEnabled,
                      (value) => setState(() => _autoPlayEnabled = value),
                    ),
                    _buildSwitchTile(
                      'WiFi Only Downloads',
                      'Download content only over WiFi',
                      Icons.wifi_outlined,
                      _downloadOverWifiOnly,
                      (value) => setState(() => _downloadOverWifiOnly = value),
                    ),
                    _buildDropdownTile(
                      'Video Quality',
                      'Default video playback quality',
                      Icons.hd_outlined,
                      _selectedQuality,
                      ['SD', 'HD', 'Full HD'],
                      (value) => setState(() => _selectedQuality = value!),
                    ),
                  ],
                ),

                _buildSettingsSection(
                  'Storage',
                  [
                    _buildActionTile(
                      'Downloaded Content',
                      'Manage offline downloads',
                      Icons.download_outlined,
                      () => _showDownloadsManager(),
                    ),
                    _buildActionTile(
                      'Clear Cache',
                      'Free up storage space',
                      Icons.clear_all_outlined,
                      () => _clearCache(),
                    ),
                  ],
                ),

                _buildSettingsSection(
                  'About',
                  [
                    _buildActionTile(
                      'Help & Support',
                      'Get help and contact support',
                      Icons.help_outline,
                      () => _showHelp(),
                    ),
                    _buildActionTile(
                      'Privacy Policy',
                      'View our privacy policy',
                      Icons.privacy_tip_outlined,
                      () => _showPrivacyPolicy(),
                    ),
                    _buildActionTile(
                      'Terms of Service',
                      'View terms and conditions',
                      Icons.description_outlined,
                      () => _showTerms(),
                    ),
                    _buildActionTile(
                      'About App',
                      'Version 1.0.0',
                      Icons.info_outline,
                      () => _showAbout(),
                    ),
                  ],
                ),

                // Sign Out Button (only show if logged in)
                Consumer<AuthService>(
                  builder: (context, authService, child) {
                    if (!authService.isLoggedIn) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      margin: const EdgeInsets.all(16),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _signOut,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Sign Out',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileSection() {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final user = authService.currentUser;
        final isLoggedIn = authService.isLoggedIn;

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Profile Picture
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1B5E20),
                      Color(0xFF23514C),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 16),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLoggedIn
                          ? 'Welcome, ${user?['username'] ?? 'Student'}'
                          : 'Welcome, Guest',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isLoggedIn
                          ? (user?['email'] ??
                              'Continue your Islamic learning journey')
                          : 'Sign in to access all features',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Edit Button
              IconButton(
                onPressed: _editProfile,
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit Profile',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF23514C),
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF23514C)),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF23514C),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    IconData icon,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF23514C)),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        underline: const SizedBox(),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF23514C)),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  void _editProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile editing coming soon!'),
        backgroundColor: Color(0xFF23514C),
      ),
    );
  }

  void _showDownloadsManager() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Downloaded Content',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
                'No downloaded content yet. Start downloading lessons for offline viewing!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will free up storage space. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully!'),
                  backgroundColor: Color(0xFF23514C),
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Help & Support'),
            backgroundColor: const Color(0xFF23514C),
          ),
          body: const Center(
            child: Text('Help & Support page coming soon!'),
          ),
        ),
      ),
    );
  }

  void _showPrivacyPolicy() {
    PrivacyPolicyScreen.show(context);
  }

  void _showTerms() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Terms of Service page coming soon!'),
        backgroundColor: Color(0xFF23514C),
      ),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Hayya Al Salah',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.mosque,
        size: 48,
        color: Color(0xFF23514C),
      ),
      children: [
        const Text(
            'An Islamic learning app for prayer, Quran, and Islamic education.'),
      ],
    );
  }

  void _signOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Use AuthService to logout
              final authService =
                  Provider.of<AuthService>(context, listen: false);
              await authService.logout();

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Signed out successfully!'),
                    backgroundColor: Color(0xFF23514C),
                  ),
                );
              }
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

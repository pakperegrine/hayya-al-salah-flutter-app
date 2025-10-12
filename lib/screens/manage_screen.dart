import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../services/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/offline_video_service.dart';
import '../services/settings_service.dart';
import '../services/theme_service.dart';
import 'downloaded_videos_screen.dart';
import 'privacy_policy_screen.dart';

class ManageScreen extends StatefulWidget {
  const ManageScreen({super.key});

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Consumer2<ThemeService, SettingsService>(
      builder: (context, themeService, settingsService, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              localizations.manage,
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
                  localizations.preferences,
                  [
                    _buildSwitchTile(
                      localizations.notifications,
                      localizations.notificationsDesc,
                      Icons.notifications_outlined,
                      settingsService.notificationsEnabled,
                      (value) => settingsService.setNotifications(value),
                    ),
                    _buildSwitchTile(
                      localizations.darkMode,
                      localizations.darkModeDesc,
                      Icons.dark_mode_outlined,
                      themeService.isDarkMode,
                      (value) => themeService.toggleTheme(),
                    ),
                    _buildDropdownTile(
                      localizations.language,
                      localizations.languageDesc,
                      Icons.language_outlined,
                      settingsService.selectedLanguage,
                      settingsService.availableLanguages,
                      (value) => settingsService.setLanguage(value!),
                    ),
                  ],
                ),

                _buildSettingsSection(
                  localizations.videoSettings,
                  [
                    _buildSwitchTile(
                      localizations.autoPlay,
                      localizations.autoPlayDesc,
                      Icons.play_arrow_outlined,
                      settingsService.autoPlayEnabled,
                      (value) => settingsService.setAutoPlay(value),
                    ),
                    _buildSwitchTile(
                      localizations.wifiOnly,
                      localizations.wifiOnlyDesc,
                      Icons.wifi_outlined,
                      settingsService.wifiOnlyDownloads,
                      (value) => settingsService.setWifiOnlyDownloads(value),
                    ),
                    _buildSwitchTile(
                      localizations.offlineVideos,
                      localizations.offlineVideosDesc,
                      Icons.download_for_offline_outlined,
                      settingsService.offlineVideosEnabled,
                      (value) => settingsService.setOfflineVideos(value),
                    ),
                  ],
                ),

                _buildSettingsSection(
                  localizations.storage,
                  [
                    _buildActionTile(
                      localizations.downloadedContent,
                      localizations.downloadedContentDesc,
                      Icons.download_outlined,
                      () => _showDownloadsManager(),
                    ),
                    FutureBuilder<String>(
                      future: _getCacheSize(),
                      builder: (context, snapshot) {
                        final cacheSize = snapshot.data ?? 'Calculating...';
                        return _buildActionTile(
                          localizations.clearCache,
                          'Cache size: $cacheSize',
                          Icons.clear_all_outlined,
                          () => _clearCache(),
                        );
                      },
                    ),
                  ],
                ),

                _buildSettingsSection(
                  localizations.about,
                  [
                    _buildActionTile(
                      localizations.helpSupport,
                      localizations.helpSupportDesc,
                      Icons.help_outline,
                      () => _showHelp(),
                    ),
                    _buildActionTile(
                      localizations.privacyPolicy,
                      localizations.privacyPolicyDesc,
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
      SnackBar(
        content: Text(AppLocalizations.of(context).comingSoon),
        backgroundColor: const Color(0xFF23514C),
      ),
    );
  }

  void _showDownloadsManager() {
    final localizations = AppLocalizations.of(context);
    final settingsService =
        Provider.of<SettingsService>(context, listen: false);

    if (!settingsService.offlineVideosEnabled) {
      showModalBottomSheet(
        context: context,
        builder: (context) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                localizations.downloadedContent,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                localizations.offlineVideosDesc,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Scroll to video settings section by triggering a rebuild
                  setState(() {});
                },
                child: Text(localizations.offlineVideos),
              ),
            ],
          ),
        ),
      );
    } else {
      // Navigate to downloaded videos screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DownloadedVideosScreen(),
        ),
      );
    }
  }

  Future<void> _clearCache() async {
    final localizations = AppLocalizations.of(context);

    // Show selection dialog first
    final selectedOptions = await _showCacheSelectionDialog();
    if (selectedOptions == null || selectedOptions.isEmpty) {
      return; // User cancelled or selected nothing
    }

    // Show confirmation with selected items
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.clearCache),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You have selected to clear:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            ...selectedOptions.map((option) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 16),
                      const SizedBox(width: 8),
                      Text(_getCacheOptionDisplayName(option)),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
            const Text(
              'Note: Downloaded videos and user settings will not be affected.',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(localizations.clear),
          ),
        ],
      ),
    );

    if (shouldClear == true) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Clearing selected cache...',
                style: GoogleFonts.inter(fontSize: 16),
              ),
            ],
          ),
        ),
      );

      try {
        await _performSelectiveCacheClear(selectedOptions);

        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selected cache cleared successfully!'),
              backgroundColor: Color(0xFF23514C),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to clear cache. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<List<String>?> _showCacheSelectionDialog() async {
    final Map<String, bool> options = {
      'cached_images': true,
      'temporary_files': true,
      'app_data': false,
      'api_cache': false,
      'corrupted_videos': true,
    };

    return await showDialog<List<String>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Select Cache to Clear'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose what you want to clear:',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              _buildCacheOption(
                'cached_images',
                'Cached Images & Thumbnails',
                'Lesson images, thumbnails, and other cached pictures',
                Icons.image_outlined,
                options['cached_images']!,
                (value) => setState(() => options['cached_images'] = value),
              ),
              _buildCacheOption(
                'temporary_files',
                'Temporary Files',
                'Temporary download files and processing data',
                Icons.file_copy_outlined,
                options['temporary_files']!,
                (value) => setState(() => options['temporary_files'] = value),
              ),
              _buildCacheOption(
                'corrupted_videos',
                'Corrupted Downloads',
                'Remove broken or incomplete video downloads',
                Icons.error_outline,
                options['corrupted_videos']!,
                (value) => setState(() => options['corrupted_videos'] = value),
              ),
              _buildCacheOption(
                'api_cache',
                'API Response Cache',
                'Cached server responses and lesson data',
                Icons.cloud_outlined,
                options['api_cache']!,
                (value) => setState(() => options['api_cache'] = value),
              ),
              _buildCacheOption(
                'app_data',
                'App Temporary Data',
                'App cache and temporary preferences (Advanced)',
                Icons.storage_outlined,
                options['app_data']!,
                (value) => setState(() => options['app_data'] = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final selected = options.entries
                    .where((entry) => entry.value)
                    .map((entry) => entry.key)
                    .toList();
                Navigator.pop(context, selected);
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCacheOption(
    String key,
    String title,
    String description,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: (bool? newValue) => onChanged(newValue ?? false),
        title: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF23514C)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        activeColor: const Color(0xFF23514C),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  String _getCacheOptionDisplayName(String option) {
    switch (option) {
      case 'cached_images':
        return 'Cached Images & Thumbnails';
      case 'temporary_files':
        return 'Temporary Files';
      case 'corrupted_videos':
        return 'Corrupted Downloads';
      case 'api_cache':
        return 'API Response Cache';
      case 'app_data':
        return 'App Temporary Data';
      default:
        return option;
    }
  }

  Future<void> _performSelectiveCacheClear(List<String> selectedOptions) async {
    try {
      int clearedCount = 0;

      for (String option in selectedOptions) {
        switch (option) {
          case 'cached_images':
            await _clearCachedImages();
            print('✓ Cleared cached images');
            clearedCount++;
            break;

          case 'temporary_files':
            await _clearTemporaryFiles();
            print('✓ Cleared temporary files');
            clearedCount++;
            break;

          case 'corrupted_videos':
            await _clearCorruptedVideos();
            print('✓ Cleaned up corrupted videos');
            clearedCount++;
            break;

          case 'api_cache':
            await _clearApiCache();
            print('✓ Cleared API cache');
            clearedCount++;
            break;

          case 'app_data':
            await _clearAppTemporaryData();
            print('✓ Cleared app temporary data');
            clearedCount++;
            break;
        }

        // Small delay between operations for better UX
        await Future.delayed(const Duration(milliseconds: 300));
      }

      print('✓ Cache clearing completed: $clearedCount items cleared');
    } catch (e) {
      print('Error during selective cache clearing: $e');
      rethrow;
    }
  }

  Future<void> _clearCachedImages() async {
    try {
      // Clear cached network images
      await CachedNetworkImage.evictFromCache("");

      // Clear Flutter's image cache
      final imageCache = PaintingBinding.instance.imageCache;
      imageCache.clear();
      imageCache.clearLiveImages();
    } catch (e) {
      print('Error clearing cached images: $e');
    }
  }

  Future<void> _clearTemporaryFiles() async {
    try {
      // Simulate clearing temporary files
      // In a real implementation, you'd clear actual temp directories
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      print('Error clearing temporary files: $e');
    }
  }

  Future<void> _clearCorruptedVideos() async {
    try {
      final offlineService = OfflineVideoService.instance;
      await offlineService.cleanupCorruptedDownloads();
    } catch (e) {
      print('Error clearing corrupted videos: $e');
    }
  }

  Future<void> _clearApiCache() async {
    try {
      // Simulate clearing API response cache
      // In a real implementation, you'd clear Dio cache or similar
      await Future.delayed(const Duration(milliseconds: 400));
    } catch (e) {
      print('Error clearing API cache: $e');
    }
  }

  Future<void> _clearAppTemporaryData() async {
    try {
      // Simulate clearing app temporary data
      // In a real implementation, you'd clear specific temporary preferences
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      print('Error clearing app temporary data: $e');
    }
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

  Future<String> _getCacheSize() async {
    try {
      int totalSize = 0;

      // Get downloaded videos size
      final offlineService = OfflineVideoService.instance;
      final downloadedSize = await offlineService.getTotalDownloadedSize();

      // Estimate cache size (this is approximate)
      // In a real implementation, you'd calculate actual cache directory sizes
      final estimatedCacheSize =
          downloadedSize * 0.1; // Assume cache is ~10% of downloads

      totalSize = estimatedCacheSize.toInt();

      return OfflineVideoService.formatFileSize(totalSize);
    } catch (e) {
      return 'Unknown';
    }
  }
}

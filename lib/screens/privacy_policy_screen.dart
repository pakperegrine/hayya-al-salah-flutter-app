import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/theme_service.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  // Static method to navigate to privacy policy screen
  static void show(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PrivacyPolicyScreen(),
      ),
    );
  }

  // Method to open privacy policy URL in browser
  static Future<void> openPrivacyPolicyUrl() async {
    final Uri url = Uri.parse('https://imtiazkausar.org.pk/privacy-policy/');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              'Privacy Policy',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            iconTheme: IconThemeData(
              color: themeService.isDarkMode
                  ? Colors.white
                  : const Color(0xFF23514C),
            ),
            actions: const [
              IconButton(
                icon: Icon(Icons.open_in_browser),
                tooltip: 'Open in browser',
                onPressed: openPrivacyPolicyUrl,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with effective date
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF23514C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF23514C).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Privacy Policy',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF23514C),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Effective Date: July 3, 2025',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Welcome to Hayya Alal Salah. This Privacy Policy describes how we handle your information. We respect your privacy and are committed to protecting it — especially for our younger users.',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          height: 1.5,
                          color: themeService.isDarkMode
                              ? Colors.white70
                              : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Section 1: No Data Collection
                _buildSection(
                  context,
                  themeService,
                  '1. No Data Collection',
                  '''Hayya Alal Salah does not collect, store, or share any personal information from users. Specifically:

• No registration or sign-in is required
• No location data, contact lists, photos, or other personal identifiers are accessed
• No cookies, tracking, or analytics tools are used''',
                ),

                const SizedBox(height: 20),

                // Section 2: App Purpose
                _buildSection(
                  context,
                  themeService,
                  '2. App Purpose',
                  '''The app provides access to a collection of video lectures by Dr. Farhat Hashmi focused on the topic of Islamic prayer (Namaz) and its correct method. All videos are embedded within the app using an in-app video player. No external platforms or logins are involved.''',
                ),

                const SizedBox(height: 20),

                // Section 3: No Third-Party Services
                _buildSection(
                  context,
                  themeService,
                  '3. No Third-Party Services',
                  '''The app does not integrate with or use third-party APIs, SDKs, or services that may collect user data.''',
                ),

                const SizedBox(height: 20),

                // Section 4: Children's Privacy
                _buildSection(
                  context,
                  themeService,
                  '4. Children\'s Privacy (COPPA Compliance)',
                  '''This app is designed to be safe for users of all ages, including children under the age of 13. We fully comply with the Children's Online Privacy Protection Act (COPPA) by:

• Not collecting or requesting any personal information from children or adults
• Not displaying ads or third-party tracking
• Not requiring sign-in or profile creation

If a parent or guardian believes that their child has provided us with personal information, they may contact us at the address below. However, since we do not collect any data, there will be nothing to delete.''',
                ),

                const SizedBox(height: 20),

                // Section 5: Changes to Policy
                _buildSection(
                  context,
                  themeService,
                  '5. Changes to This Privacy Policy',
                  '''We may update this Privacy Policy from time to time to reflect changes in the app or legal requirements. Any changes will be posted on this page. Continued use of the app means you accept any updated terms.''',
                ),

                const SizedBox(height: 20),

                // Section 6: Contact Us
                _buildSection(
                  context,
                  themeService,
                  '6. Contact Us',
                  '''If you have questions about this Privacy Policy or your experience with the app, please contact us:

Email: info@imtiazkausar.org.pk
Developer: Pak Peregrine Corporation

By using this app, you agree to the terms outlined in this Privacy Policy.''',
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(
    BuildContext context,
    ThemeService themeService,
    String title,
    String content,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeService.isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              themeService.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF23514C),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.6,
              color:
                  themeService.isDarkMode ? Colors.white70 : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/prayer_steps_data.dart';
import '../models/preyer_model.dart';
import '../models/topic.dart';

class PrayerAnimationScreen extends StatefulWidget {
  final Topic topic;

  const PrayerAnimationScreen({
    super.key,
    required this.topic,
  });

  @override
  State<PrayerAnimationScreen> createState() => _PrayerAnimationScreenState();
}

class _PrayerAnimationScreenState extends State<PrayerAnimationScreen> {
  final PageController _pageController = PageController();
  int _currentSliderIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Helper method to determine text direction based on content
  TextDirection _getTextDirection(String text) {
    if (text.isEmpty) return TextDirection.ltr;

    // Check if text contains Arabic, Urdu, or other RTL characters
    final rtlRegex = RegExp(
        r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF\u200F\u202B\u202E]');
    if (rtlRegex.hasMatch(text)) {
      return TextDirection.rtl;
    }
    return TextDirection.ltr;
  }

  /// Create a text widget with proper Unicode support
  Widget buildUnicodeText(
    String text, {
    TextStyle? style,
    int? maxLines,
    TextOverflow? overflow,
    TextAlign? textAlign,
  }) {
    final isRtl = _getTextDirection(text) == TextDirection.rtl;

    // Define fallback fonts for different scripts
    List<String> fontFallbacks = [
      if (isRtl) ...[
        'Noto Sans Arabic',
        'Noto Nastaliq Urdu',
        'Arabic Typesetting',
        'Traditional Arabic',
        'Segoe UI Historic',
      ],
      'Roboto',
      'Arial',
      'sans-serif',
    ];

    return Directionality(
      textDirection: _getTextDirection(text),
      child: Text(
        text,
        style: TextStyle(
          fontFamilyFallback: fontFallbacks,
          fontSize: style?.fontSize ?? 16,
          fontWeight: style?.fontWeight,
          color: style?.color ?? Colors.black87,
          height: style?.height ??
              (isRtl ? 1.8 : 1.5), // Better line height for Urdu
        ),
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign ?? (isRtl ? TextAlign.right : TextAlign.left),
        textDirection: _getTextDirection(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: buildUnicodeText(
          'Topic: ${widget.topic.title}',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Topic Header (separated from slider)
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1B5E20),
                  Color(0xFF23514C),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildUnicodeText(
                    widget.topic.title,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  buildUnicodeText(
                    widget.topic.description,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.video_library,
                        '${prayerSteps.length} slides',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // White Background Slider Section (detached)
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  // Dots Indicator at Top
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        prayerSteps.length,
                        (index) => _buildDotIndicator(index),
                      ),
                    ),
                  ),

                  // Slider
                  Expanded(
                    flex: 4,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentSliderIndex = index;
                        });
                      },
                      itemCount: prayerSteps.length,
                      itemBuilder: (context, index) {
                        final item = prayerSteps[index];
                        return _buildSliderItem(item);
                      },
                    ),
                  ),

                  // Verses Section
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        border: Border(
                          top: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: Text(
                              'قراءة الصلاة',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1B5E20),
                              ),
                            ),
                          ),
                          Expanded(
                            child: (prayerSteps[_currentSliderIndex]
                                        .verses
                                        ?.isEmpty ??
                                    true)
                                ? Center(
                                    child: Text(
                                      'لا توجد آيات متاحة',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    itemCount: prayerSteps[_currentSliderIndex]
                                            .verses
                                            ?.length ??
                                        0,
                                    itemBuilder: (context, index) {
                                      final verse =
                                          prayerSteps[_currentSliderIndex]
                                              .verses![index];
                                      if (verse.isEmpty)
                                        return const SizedBox.shrink();
                                      return Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 2),
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: const Color(0xFF1B5E20)
                                                .withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          verse,
                                          style: GoogleFonts.amiri(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                            height: 1.8,
                                          ),
                                          textAlign: TextAlign.center,
                                          textDirection: TextDirection.rtl,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderItem(PrayerSliderItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // SVG Icon
          Container(
            width: 200,
            height: 180,
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              // color: const Color(0xFF1B5E20).withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
              // border: Border.all(
              //   color: const Color(0xFF1B5E20).withOpacity(0.3),
              //   width: 2,
              // ),
            ),
            child: SvgPicture.asset(
              item.svgPath,
              color: const Color(0xFF1B5E20),
              width: 100,
              height: 100,
            ),
          ),

          const SizedBox(height: 8),

          // Main Title
          Text(
            item.title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1B5E20),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 3),
          // Main Title
          Text(
            item.arabic,
            style: GoogleFonts.amiri(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1B5E20),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 2),

          // Urdu
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF1B5E20).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              item.urdu,
              style: GoogleFonts.amiri(
                fontSize: 14,
                height: 1.3,
                color: Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
          ),

          const SizedBox(height: 2),

          // english
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF1B5E20).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: buildUnicodeText(
              item.english,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.black87,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentSliderIndex == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentSliderIndex == index
            ? const Color(0xFF1B5E20)
            : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

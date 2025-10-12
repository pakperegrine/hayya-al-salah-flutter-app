import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/quran_verse.dart';
import '../models/topic.dart';
import '../services/api_service.dart';
import '../services/islamic_calendar_service.dart';
import '../services/quran_api_service.dart';
import 'lesson_detail_screen.dart';
import 'notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final QuranApiService _quranService = QuranApiService();
  final IslamicCalendarService _calendarService = IslamicCalendarService();
  final ApiService _apiService = ApiService();

  QuranVerse? _currentVerse;
  bool _isLoadingVerse = true;
  Map<String, String> _currentDate = {};
  List<Topic> _topics = [];
  bool _isLoadingTopics = false;
  int _notificationCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCurrentDate();
    _loadRandomVerse();
    _loadTopics();
    _loadNotificationCount();
  }

  void _loadCurrentDate() {
    setState(() {
      _currentDate = _calendarService.getCurrentDate();
    });
  }

  Future<void> _loadRandomVerse() async {
    setState(() {
      _isLoadingVerse = true;
    });

    try {
      final verse = await _quranService.getRandomVerse();
      setState(() {
        _currentVerse = verse;
        _isLoadingVerse = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingVerse = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load verse')),
      );
    }
  }

  Future<void> _loadTopics() async {
    setState(() {
      _isLoadingTopics = true;
    });

    try {
      await _apiService.initialize();
      final topics = await _apiService.getTopics();
      setState(() {
        _topics = topics.isNotEmpty ? topics : _getSampleTopics();
        _isLoadingTopics = false;
      });
    } catch (e) {
      setState(() {
        _topics = _getSampleTopics(); // Fallback to sample data
        _isLoadingTopics = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to load topics, showing sample data')),
      );
    }
  }

  Future<void> _loadNotificationCount() async {
    try {
      await _apiService.initialize();
      final count = await _apiService.getUnreadNotificationCount();
      setState(() {
        _notificationCount = count;
      });
    } catch (e) {
      print('Failed to load notification count: $e');
      // Keep default count of 0
    }
  }

  // Fallback sample topics if API fails
  List<Topic> _getSampleTopics() {
    return [
      Topic(
        id: '1',
        title: 'Salah Lessons',
        description: 'By Dr. Farhat Hashmi',
        imageUrl: '',
        lessonsCount: 80,
        duration: '2 hours',
        lessons: [],
      ),
      Topic(
        id: '2',
        title: 'Salah Guide',
        description: 'Step by Step Salah guide',
        imageUrl: '',
        lessonsCount: 12,
        duration: '3 hours',
        lessons: [],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Hayya Al Salah',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF23514C),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
                onPressed: () async {
                  // Navigate to notifications screen
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NotificationScreen(),
                    ),
                  );

                  // Refresh notification count when returning from notifications
                  if (mounted) {
                    await _loadNotificationCount();
                  }
                },
                tooltip: 'Notifications',
              ),
              // Notification badge
              if (_notificationCount > 0)
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _notificationCount > 99
                          ? '99+'
                          : _notificationCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadCurrentDate();
          await _loadRandomVerse();
          await _loadTopics();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Banner
              _buildDateBanner(),

              // Quranic Verse Section
              _buildQuranVerseSection(),

              // Topics Section
              _buildTopicsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        width: double.infinity,
        height: 180, // Increased height
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), // More rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          image: const DecorationImage(
            image: AssetImage('assets/images/top-banner.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Gradient overlay for better text readability
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.transparent,
              ),
            ),
            // Text content aligned to top-left
            Positioned(
              top: 0,
              left: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(
                    _currentDate['gregorian'] ?? 'Loading...',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentDate['islamic'] ?? 'Loading...',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuranVerseSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_stories,
                    color: Color(0xFF23514C),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Verse from the Qur\'an',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF23514C),
                    ),
                  ),
                ],
              ),
              // Refresh button moved here
              IconButton(
                icon: const Icon(
                  Icons.refresh,
                  color: Color(0xFF23514C),
                ),
                onPressed: _loadRandomVerse,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingVerse)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (_currentVerse != null) ...[
            // Arabic Text
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _currentVerse!.arabicText,
                style: GoogleFonts.amiri(
                  fontSize: 20,
                  height: 1.8,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
            ),
            const SizedBox(height: 12),

            // English Translation
            Text(
              'English Translation:',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _currentVerse!.englishTranslation,
              style: GoogleFonts.inter(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Urdu Translation
            Text(
              'Urdu Translation:',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _currentVerse!.urduTranslation,
              style: GoogleFonts.inter(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 12),

            // Surah Info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF23514C),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentVerse!.surahNameEnglish} ${_currentVerse!.surah}:${_currentVerse!.ayah}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ] else
            const Text('Failed to load verse'),
        ],
      ),
    );
  }

  Widget _buildTopicsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Islamic Topics',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _isLoadingTopics
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF23514C),
                  ),
                )
              : SizedBox(
                  height: 220, // Reduced height from 250 to 220
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _topics
                          .map((topic) => _buildTopicCard(topic))
                          .toList(),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildTopicCard(Topic topic) {
    return Container(
      width: 180, // Increased width for better text layout
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LessonDetailScreen(topic: topic),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFF23514C),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.play_circle_outline,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              // Use Expanded to prevent overflow
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      topic.description,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8), // Fixed spacing
                    Text(
                      '${topic.lessonsCount} lessons',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

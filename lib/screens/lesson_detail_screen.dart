import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/topic.dart';
import '../services/api_service.dart';
import '../services/app_localizations.dart';
import '../services/favorites_service.dart';
import '../services/offline_video_service.dart';
import '../services/settings_service.dart';
import 'video_player_screen.dart';

class LessonDetailScreen extends StatefulWidget {
  final Topic topic;

  const LessonDetailScreen({
    super.key,
    required this.topic,
  });

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  final FavoritesService _favoritesService = FavoritesService.instance;
  final OfflineVideoService _offlineService = OfflineVideoService.instance;

  List<Lesson> _filteredLessons = [];
  List<Lesson> _allLessons = [];
  bool _isLoadingLessons = false;
  final Map<String, bool> _downloadingLessons = {};
  final Map<String, double> _downloadProgress = {};

  @override
  void initState() {
    super.initState();
    _loadLessons();
    _searchController.addListener(_filterLessons);
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLessons() async {
    setState(() {
      _isLoadingLessons = true;
    });

    try {
      await _apiService.initialize();

      // Try to get lessons by topic ID if it's a number
      List<Lesson> lessons = [];
      final topicId = int.tryParse(widget.topic.id);

      if (topicId != null) {
        lessons = await _apiService.getLecturesByTopic(topicId);
      }

      // If no lessons from API or topic ID is not a number, use sample data
      if (lessons.isEmpty) {
        lessons = _getSampleLessons();
      }

      setState(() {
        _allLessons = lessons;
        _filteredLessons = lessons;
        _isLoadingLessons = false;
      });

      // Debug: Print first lesson title to see the actual text
      if (lessons.isNotEmpty) {
        print('First lesson title: "${lessons.first.title}"');
        print('Title length: ${lessons.first.title.length}');
        print('Title codeUnits: ${lessons.first.title.codeUnits}');
      }
    } catch (e) {
      setState(() {
        _allLessons = _getSampleLessons(); // Fallback to sample data
        _filteredLessons = _allLessons;
        _isLoadingLessons = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to load lessons, showing sample data')),
        );
      }
    }
  }

  void _filterLessons() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredLessons = _allLessons;
      } else {
        _filteredLessons = _allLessons.where((lesson) {
          return lesson.title.toLowerCase().contains(query) ||
              lesson.description.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: buildUnicodeText(
          'Topic: ${widget.topic.title}',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          // Topic Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1B5E20),
                  Color(0xFF23514C),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildUnicodeText(
                  widget.topic.title,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    color: Colors.white,
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
                      '${widget.topic.lessonsCount} lessons',
                    ),
                    const SizedBox(width: 12),
                    _buildInfoChip(
                      Icons.access_time,
                      widget.topic.duration,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lessons List
          Expanded(
            child: Column(
              children: [
                // Search Bar
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search lessons...',
                      hintStyle: GoogleFonts.inter(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(context).primaryColor,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _filterLessons();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: GoogleFonts.inter(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),

                // Lessons List
                Expanded(
                  child: _isLoadingLessons
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF23514C),
                          ),
                        )
                      : _filteredLessons.isEmpty &&
                              _searchController.text.isNotEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No lessons found',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Try searching with different keywords',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadLessons,
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _filteredLessons.length,
                                itemBuilder: (context, index) {
                                  final lesson = _filteredLessons[index];
                                  final originalIndex =
                                      _allLessons.indexOf(lesson);
                                  return _buildLessonCard(
                                      lesson, originalIndex);
                                },
                              ),
                            ),
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildLessonCard(Lesson lesson, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(
                lesson: lesson,
                relatedLessons: _allLessons,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Lesson Number
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Lesson Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    buildUnicodeText(
                      lesson.title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    buildUnicodeText(
                      lesson.description,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.play_circle_outline,
                          size: 16,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lesson.duration,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                        if (lesson.referenceFileUrl != null) ...[
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () => _downloadReference(lesson),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.download,
                                  size: 16,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Reference',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Column(
                children: [
                  // Favorite Button
                  FutureBuilder<bool>(
                    future: _favoritesService.isFavorite(lesson.id),
                    builder: (context, snapshot) {
                      final isFavorite = snapshot.data ?? false;
                      return IconButton(
                        onPressed: () => _toggleFavorite(lesson),
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color:
                              isFavorite ? Colors.red[400] : Colors.grey[600],
                          size: 20,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      );
                    },
                  ),

                  const SizedBox(height: 8),

                  // Download Button
                  Consumer<SettingsService>(
                    builder: (context, settingsService, child) {
                      if (!settingsService.offlineVideosEnabled) {
                        return const SizedBox.shrink();
                      }

                      return FutureBuilder<bool>(
                        future: _offlineService.isLessonDownloaded(lesson.id),
                        builder: (context, snapshot) {
                          final isDownloaded = snapshot.data ?? false;
                          final isDownloading =
                              _downloadingLessons[lesson.id] ?? false;
                          final progress = _downloadProgress[lesson.id] ?? 0.0;

                          if (isDownloading) {
                            return SizedBox(
                              width: 32,
                              height: 32,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: 2,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  Text(
                                    '${(progress * 100).toInt()}%',
                                    style: GoogleFonts.inter(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return IconButton(
                            onPressed: isDownloaded
                                ? () => _deleteDownloadedLesson(lesson)
                                : () => _downloadLesson(lesson),
                            icon: Icon(
                              isDownloaded
                                  ? Icons.download_done
                                  : Icons.download_outlined,
                              color: isDownloaded
                                  ? Colors.green
                                  : Theme.of(context).primaryColor,
                              size: 20,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            padding: EdgeInsets.zero,
                          );
                        },
                      );
                    },
                  ),

                  // Play Button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Lesson> _getSampleLessons() {
    // Generate sample lessons based on topic
    return List.generate(widget.topic.lessonsCount, (index) {
      return Lesson(
        id: '${widget.topic.id}-${index + 1}',
        title: 'Lesson ${index + 1}: ${_getLessonTitle(index)}',
        description: _getLessonDescription(index),
        videoUrl:
            'https://sample-video-url.com/${widget.topic.id}-${index + 1}',
        thumbnailUrl: '',
        duration: _generateDuration(index),
        lessonNumber: index + 1,
        referenceFileUrl: index % 2 == 0
            ? 'https://sample-pdf.com/reference-${index + 1}.pdf'
            : null,
      );
    });
  }

  String _getLessonTitle(int index) {
    switch (widget.topic.id) {
      case '1': // Prayer Basics
        final prayerTitles = [
          'Introduction to Salah',
          'Importance of Prayer',
          'Times of Prayer',
          'Preparing for Prayer',
          'Steps of Prayer',
          'Common Mistakes',
          'Du\'a and Dhikr',
          'Prayer in Congregation',
        ];
        return prayerTitles[index % prayerTitles.length];

      case '2': // Quran Recitation
        final quranTitles = [
          'Arabic Alphabet',
          'Basic Pronunciation',
          'Tajweed Rules',
          'Short Surahs',
          'Reading Practice',
          'Memorization Tips',
          'Beautiful Recitation',
          'Understanding Meanings',
        ];
        return quranTitles[index % quranTitles.length];

      default:
        return 'Introduction and Basics';
    }
  }

  String _getLessonDescription(int index) {
    return 'Comprehensive lesson covering important aspects of ${widget.topic.title.toLowerCase()}. This lesson will help you understand the key concepts and practical applications.';
  }

  String _generateDuration(int index) {
    final durations = [
      '15:30',
      '12:45',
      '18:20',
      '22:10',
      '16:55',
      '20:30',
      '14:15',
      '25:40'
    ];
    return durations[index % durations.length];
  }

  Future<void> _toggleFavorite(Lesson lesson) async {
    try {
      final isFavorite = await _favoritesService.isFavorite(lesson.id);
      bool success;

      if (isFavorite) {
        success = await _favoritesService.removeFromFavorites(lesson.id);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Removed from favorites'),
              backgroundColor: Color(0xFF23514C),
            ),
          );
        }
      } else {
        success = await _favoritesService.addToFavorites(lesson);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Added to favorites'),
              backgroundColor: Color(0xFF23514C),
            ),
          );
        }
      }

      // Trigger rebuild to update the favorite icon
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update favorites'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadReference(Lesson lesson) async {
    if (lesson.referenceFileUrl == null || lesson.referenceFileUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No reference material available'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Extract filename from URL or create a default one
      final uri = Uri.parse(lesson.referenceFileUrl!);
      String fileName = uri.pathSegments.isNotEmpty
          ? uri.pathSegments.last
          : 'reference_material_${lesson.id}.pdf';

      // If no extension in filename, add .pdf as default
      if (!fileName.contains('.')) {
        fileName = '$fileName.pdf';
      }

      print('Downloading reference: ${lesson.referenceFileUrl!}');
      print('Filename: $fileName');

      // Use the new download method
      await _downloadFile(lesson.referenceFileUrl!, fileName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening reference material: ${lesson.title}'),
            backgroundColor: const Color(0xFF23514C),
          ),
        );
      }
    } catch (e) {
      print('Error downloading reference: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to open reference material'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadFile(String url, String fileName) async {
    final Uri uri = Uri.parse(url);
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _downloadLesson(Lesson lesson) async {
    final localizations = AppLocalizations.of(context);
    final settingsService =
        Provider.of<SettingsService>(context, listen: false);

    if (!settingsService.offlineVideosEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.offlineVideosDesc),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check if already downloaded
    if (await _offlineService.isLessonDownloaded(lesson.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.downloaded),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    // Start download
    setState(() {
      _downloadingLessons[lesson.id] = true;
      _downloadProgress[lesson.id] = 0.0;
    });

    final success = await _offlineService.downloadLesson(
      lesson,
      onProgress: (progress) {
        setState(() {
          _downloadProgress[lesson.id] = progress;
        });
      },
      onError: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${localizations.downloadFailed}: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );

    setState(() {
      _downloadingLessons[lesson.id] = false;
      _downloadProgress.remove(lesson.id);
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.downloadCompleted),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _deleteDownloadedLesson(Lesson lesson) async {
    final localizations = AppLocalizations.of(context);

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.deleteDownload),
        content: Text(localizations.deleteDownloadConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(localizations.delete),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      final success = await _offlineService.deleteDownloadedLesson(lesson.id);
      if (success && mounted) {
        setState(() {}); // Refresh UI
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.videoDeletedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}

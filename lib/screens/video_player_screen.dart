import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../models/topic.dart';
import '../services/favorites_service.dart';
import '../services/offline_video_service.dart';
import '../services/settings_service.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Lesson lesson;
  final List<Lesson> relatedLessons;

  const VideoPlayerScreen({
    super.key,
    required this.lesson,
    required this.relatedLessons,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isPlayerReady = false;
  bool _isFavorite = false;
  final FavoritesService _favoritesService = FavoritesService.instance;

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
          height: style?.height ?? (isRtl ? 1.8 : 1.5),
        ),
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign ?? (isRtl ? TextAlign.right : TextAlign.left),
        textDirection: _getTextDirection(text),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _checkFavoriteStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh favorite status when returning to this screen
    _checkFavoriteStatus();
  }

  void _checkFavoriteStatus() async {
    final isFavorite = await _favoritesService.isFavorite(widget.lesson.id);
    setState(() {
      _isFavorite = isFavorite;
    });
  }

  void _toggleFavorite() async {
    if (_isFavorite) {
      // Remove from favorites
      final success =
          await _favoritesService.removeFromFavorites(widget.lesson.id);
      if (success) {
        setState(() {
          _isFavorite = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Removed from favorites'),
              backgroundColor: Color(0xFF23514C),
            ),
          );
        }
      }
    } else {
      // Add to favorites
      final success = await _favoritesService.addToFavorites(widget.lesson);
      if (success) {
        setState(() {
          _isFavorite = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Added to favorites'),
              backgroundColor: Color(0xFF23514C),
            ),
          );
        }
      }
    }
  }

  void _initializePlayer() async {
    try {
      final offlineService = OfflineVideoService.instance;
      String videoUrl = widget.lesson.videoUrl;

      // Check if video is available offline
      final localPath =
          await offlineService.getLocalVideoPath(widget.lesson.id);
      if (localPath != null) {
        print('Playing offline video: $localPath');

        // Verify file exists and is accessible before using it
        final file = File(localPath);
        if (await file.exists()) {
          try {
            final fileSize = await file.length();
            print('Offline video file size: $fileSize bytes');

            if (fileSize > 0) {
              _videoController = VideoPlayerController.file(file);
            } else {
              print('Offline video file is empty, falling back to online');
              throw Exception('Offline video file is empty');
            }
          } catch (e) {
            print('Error accessing offline video file: $e');
            throw Exception('Cannot access offline video file');
          }
        } else {
          print('Offline video file does not exist, falling back to online');
          throw Exception('Offline video file not found');
        }
      } else {
        print('No offline video available, playing online video: $videoUrl');
        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(videoUrl),
          httpHeaders: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          },
        );
      }

      await _videoController!.initialize();

      // Add listener for video completion to handle autoplay
      _videoController!.addListener(_videoPlayerListener);

      final settingsService =
          Provider.of<SettingsService>(context, listen: false);

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: settingsService.autoPlayEnabled,
        looping: false,
        aspectRatio: _videoController!.value.aspectRatio,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFF23514C),
          handleColor: const Color(0xFF23514C),
          backgroundColor: Colors.grey,
          bufferedColor: Colors.grey[300]!,
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF23514C),
            ),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading video',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorMessage,
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (mounted) {
        setState(() {
          _isPlayerReady = true;
        });
      }
    } catch (error) {
      print('Video initialization error: $error');

      // If offline video failed, try to fallback to online video
      if (error.toString().contains('offline') ||
          error.toString().contains('file')) {
        try {
          print(
              'Attempting fallback to online video: ${widget.lesson.videoUrl}');
          _videoController?.dispose();

          _videoController = VideoPlayerController.networkUrl(
            Uri.parse(widget.lesson.videoUrl),
            httpHeaders: {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            },
          );

          await _videoController!.initialize();
          _videoController!.addListener(_videoPlayerListener);

          final settingsService =
              Provider.of<SettingsService>(context, listen: false);

          _chewieController = ChewieController(
            videoPlayerController: _videoController!,
            autoPlay: settingsService.autoPlayEnabled,
            looping: false,
            aspectRatio: _videoController!.value.aspectRatio,
            materialProgressColors: ChewieProgressColors(
              playedColor: const Color(0xFF23514C),
              handleColor: const Color(0xFF23514C),
              backgroundColor: Colors.grey,
              bufferedColor: Colors.grey[300]!,
            ),
          );

          if (mounted) {
            setState(() {
              _isPlayerReady = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Offline video failed, playing online version'),
                backgroundColor: Colors.orange,
              ),
            );
          }

          // Clean up corrupted offline file
          final offlineService = OfflineVideoService.instance;
          await offlineService.deleteDownloadedLesson(widget.lesson.id);

          return;
        } catch (fallbackError) {
          print('Fallback to online video also failed: $fallbackError');
        }
      }

      if (mounted) {
        setState(() {
          _isPlayerReady = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load video: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Add listener for video completion to handle autoplay
  void _videoPlayerListener() async {
    if (_videoController != null && _videoController!.value.isInitialized) {
      final duration = _videoController!.value.duration;
      final position = _videoController!.value.position;

      // Check if video has finished playing (within 1 second of completion)
      if (duration.inSeconds > 0 &&
          (position.inSeconds >= duration.inSeconds - 1) &&
          !_videoController!.value.isPlaying) {
        await _handleVideoCompletion();
      }
    }
  }

  Future<void> _handleVideoCompletion() async {
    final settingsService =
        Provider.of<SettingsService>(context, listen: false);

    // Check if autoplay is enabled
    if (!settingsService.autoPlayEnabled) {
      return;
    }

    // Find next lesson from related videos with same lesson number
    final nextLesson = _findNextLesson();

    if (nextLesson != null) {
      // Show autoplay countdown dialog
      final shouldAutoplay = await _showAutoplayDialog(nextLesson);

      if (shouldAutoplay && mounted) {
        // Navigate to next lesson
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(
              lesson: nextLesson,
              relatedLessons: widget.relatedLessons,
            ),
          ),
        );
      }
    }
  }

  Lesson? _findNextLesson() {
    // Filter related lessons with same lesson number, excluding current lesson
    final sameLessonVideos = widget.relatedLessons
        .where((lesson) =>
            lesson.id != widget.lesson.id &&
            lesson.lessonNumber == widget.lesson.lessonNumber)
        .toList();

    if (sameLessonVideos.isEmpty) {
      return null;
    }

    // Sort by title or ID to get consistent ordering
    sameLessonVideos.sort((a, b) => a.title.compareTo(b.title));

    // Return the first one (you can implement more sophisticated logic here)
    return sameLessonVideos.first;
  }

  Future<bool> _showAutoplayDialog(Lesson nextLesson) async {
    int countdown = 5;
    bool shouldAutoplay = true;

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => StatefulBuilder(
            builder: (context, setState) {
              // Start countdown timer
              if (countdown > 0) {
                Future.delayed(const Duration(seconds: 1), () {
                  if (mounted && countdown > 0) {
                    setState(() {
                      countdown--;
                    });
                    if (countdown == 0 && shouldAutoplay) {
                      Navigator.of(context).pop(true);
                    }
                  }
                });
              }

              return AlertDialog(
                title: const Text('Autoplay Next Lesson'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Next lesson will start in:'),
                    const SizedBox(height: 16),
                    Text(
                      '$countdown',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF23514C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    buildUnicodeText(
                      nextLesson.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      shouldAutoplay = false;
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF23514C),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Play Now'),
                  ),
                ],
              );
            },
          ),
        ) ??
        false;
  }

  @override
  void dispose() {
    _videoController?.removeListener(_videoPlayerListener);
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: buildUnicodeText(
          widget.lesson.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: _shareLesson,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Video Player Section
          Container(
            width: double.infinity,
            height: 250,
            color: Colors.black,
            child: _isPlayerReady
                ? _buildVideoPlayer()
                : const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF23514C),
                    ),
                  ),
          ),

          // Content Section
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Lesson Info
                  _buildLessonInfo(),

                  // Related Lessons
                  Expanded(
                    child: _buildRelatedLessons(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_chewieController != null && _videoController!.value.isInitialized) {
      return Chewie(controller: _chewieController!);
    } else {
      // Show loading or error state
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFF23514C),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading video...',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Duration: ${widget.lesson.duration}',
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildLessonInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lesson Title
          buildUnicodeText(
            widget.lesson.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          // Lesson Description
          buildUnicodeText(
            widget.lesson.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // Lesson Meta Info
          Row(
            children: [
              _buildMetaInfo(Icons.play_circle_outline, widget.lesson.duration),
              const SizedBox(width: 20),
              _buildMetaInfo(Icons.format_list_numbered,
                  'Lesson ${widget.lesson.lessonNumber}'),
              if (widget.lesson.referenceFileUrl != null) ...[
                const SizedBox(width: 20),
                _buildMetaInfo(Icons.attach_file, 'Reference'),
              ],
              const Spacer(),
              // Add to Favorites Button
              IconButton(
                onPressed: _toggleFavorite,
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.grey[600],
                ),
                tooltip:
                    _isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
              ),
            ],
          ),

          // Download Reference Button
          if (widget.lesson.referenceFileUrl != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _downloadReference,
                icon: const Icon(Icons.download),
                label: const Text('Download Reference Material'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF23514C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetaInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedLessons() {
    // Filter related lessons to only show those with the same lesson number
    final filteredLessons = widget.relatedLessons
        .where((lesson) =>
            lesson.id != widget.lesson.id &&
            lesson.lessonNumber == widget.lesson.lessonNumber)
        .toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Related Lessons (Lesson ${widget.lesson.lessonNumber})',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Consumer<SettingsService>(
                builder: (context, settings, child) {
                  if (settings.autoPlayEnabled && filteredLessons.isNotEmpty) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF23514C).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.play_arrow,
                            size: 16,
                            color: const Color(0xFF23514C),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Autoplay',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF23514C),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filteredLessons.isEmpty
                ? Center(
                    child: Text(
                      'No other lessons found for lesson ${widget.lesson.lessonNumber}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredLessons.length
                        .clamp(0, 5), // Show max 5 related lessons
                    itemBuilder: (context, index) {
                      final lesson = filteredLessons[index];
                      final isNext =
                          index == 0; // First lesson will be next for autoplay
                      return _buildRelatedLessonCard(lesson, isNext);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedLessonCard(Lesson lesson, [bool isNext = false]) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNext ? const Color(0xFF23514C) : Colors.grey[200]!,
          width: isNext ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(
                lesson: lesson,
                relatedLessons: widget.relatedLessons,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail
              Container(
                width: 60,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFF23514C),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: isNext
                    ? Stack(
                        children: [
                          const Center(
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.skip_next,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                        ],
                      )
                    : const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 24,
                      ),
              ),

              const SizedBox(width: 12),

              // Lesson Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: buildUnicodeText(
                            lesson.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isNext
                                  ? const Color(0xFF23514C)
                                  : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isNext) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Next',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lesson.duration,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadReference() async {
    if (widget.lesson.referenceFileUrl == null ||
        widget.lesson.referenceFileUrl!.isEmpty) {
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
      final uri = Uri.parse(widget.lesson.referenceFileUrl!);
      String fileName = uri.pathSegments.isNotEmpty
          ? uri.pathSegments.last
          : 'reference_material_${widget.lesson.id}.pdf';

      // If no extension in filename, add .pdf as default
      if (!fileName.contains('.')) {
        fileName = '$fileName.pdf';
      }

      print('Downloading reference: ${widget.lesson.referenceFileUrl!}');
      print('Filename: $fileName');

      // Use the new download method
      await _downloadFile(widget.lesson.referenceFileUrl!, fileName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening reference material: ${widget.lesson.title}'),
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

  void _shareLesson() {
    // Implement lesson sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing lesson...'),
        backgroundColor: Color(0xFF23514C),
      ),
    );
  }
}

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

import '../models/topic.dart';
import '../services/favorites_service.dart';

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
      // Initialize video player with the lesson's video URL
      print('Initializing video: ${widget.lesson.videoUrl}');

      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.lesson.videoUrl),
        httpHeaders: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      await _videoController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
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

  @override
  void dispose() {
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
          if (widget.lesson.referenceFileUrl != null)
            IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              onPressed: _downloadReference,
            ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareLesson,
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
          Text(
            'Related Lessons (Lesson ${widget.lesson.lessonNumber})',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
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
                      return _buildRelatedLessonCard(lesson);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedLessonCard(Lesson lesson) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
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
                child: const Icon(
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
                    buildUnicodeText(
                      lesson.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  void _downloadReference() {
    // Implement reference file download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Downloading reference material...'),
        backgroundColor: Color(0xFF23514C),
      ),
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

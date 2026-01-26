import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../data/wudu_steps_data.dart';
import '../models/topic.dart';
import '../models/wudu_model.dart';

class WuduAnimationScreen extends StatefulWidget {
  final Topic topic;

  const WuduAnimationScreen({
    super.key,
    required this.topic,
  });

  @override
  State<WuduAnimationScreen> createState() => _WuduAnimationScreenState();
}

class _WuduAnimationScreenState extends State<WuduAnimationScreen> {
  final PageController _pageController = PageController();
  int _currentStepIndex = 0;
  VideoPlayerController? _currentVideoController;
  bool _isVideoInitialized = false;
  bool _isVideoCompleted = false;
  double _downloadProgress = 0.0;
  bool _isDownloading = false;
  final Dio _dio = Dio();
  CancelToken? _activeDownloadCancelToken;
  CancelToken? _prefetchCancelToken;
  String? _prefetchUrl;
  Future<File?>? _prefetchFuture;

  static const Map<String, String> _videoHttpHeaders = {
    // Some hosts block unknown/default User-Agents and may return HTML.
    'User-Agent':
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'video/*,*/*;q=0.8',
  };

  @override
  void initState() {
    super.initState();
    _initializeVideo(_currentStepIndex);
  }

  @override
  void dispose() {
    _cancelActiveDownload();
    _cancelPrefetch();
    _currentVideoController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _cancelActiveDownload() {
    final token = _activeDownloadCancelToken;
    if (token != null && !token.isCancelled) {
      token.cancel('User navigated to another step');
    }
    _activeDownloadCancelToken = null;

    if (mounted && _isDownloading) {
      setState(() {
        _isDownloading = false;
        _downloadProgress = 0.0;
      });
    }
  }

  void _cancelPrefetch() {
    final token = _prefetchCancelToken;
    if (token != null && !token.isCancelled) {
      token.cancel('Prefetch cancelled');
    }
    _prefetchCancelToken = null;
    _prefetchUrl = null;
    _prefetchFuture = null;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    final wuduCacheDir = Directory('${directory.path}/wudu_videos');
    if (!await wuduCacheDir.exists()) {
      await wuduCacheDir.create(recursive: true);
    }
    return wuduCacheDir.path;
  }

  String _getVideoFileName(String videoUrl) {
    return videoUrl.split('/').last;
  }

  Future<File?> _getCachedVideo(String videoUrl) async {
    try {
      final path = await _localPath;
      final fileName = _getVideoFileName(videoUrl);
      final file = File('$path/$fileName');

      if (await file.exists()) {
        // Basic validation: size + MP4 signature.
        final fileSize = await file.length();
        if (fileSize > 1024 && await _isLikelyMp4File(file)) {
          debugPrint('Found cached video: ${file.path}, size: $fileSize bytes');
          return file;
        }

        debugPrint('Cached file looks invalid, deleting: ${file.path}');
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error checking cached video: $e');
    }
    return null;
  }

  Future<bool> _isLikelyMp4File(File file) async {
    try {
      if (!await file.exists()) return false;

      // MP4 typically has an ftyp box near the start. We scan the first 64 bytes.
      final bytes = await file.openRead(0, 64).fold<List<int>>(
        <int>[],
        (acc, data) {
          acc.addAll(data);
          return acc;
        },
      );

      if (bytes.length < 12) return false;

      // Look for ASCII 'ftyp' within the first 32 bytes.
      for (int i = 0; i <= bytes.length - 4 && i < 32; i++) {
        if (bytes[i] == 0x66 &&
            bytes[i + 1] == 0x74 &&
            bytes[i + 2] == 0x79 &&
            bytes[i + 3] == 0x70) {
          return true;
        }
      }

      return false;
    } catch (_) {
      return false;
    }
  }

  Future<File?> _downloadAndCacheVideo(String videoUrl) async {
    // Stop any previous download when a new step starts.
    _cancelActiveDownload();

    final cancelToken = CancelToken();
    _activeDownloadCancelToken = cancelToken;

    try {
      final path = await _localPath;
      final fileName = _getVideoFileName(videoUrl);
      final savePath = '$path/$fileName';
      final file = File(savePath);

      // Double-check if file exists before downloading
      if (await file.exists()) {
        final fileSize = await file.length();
        if (fileSize > 1024 && await _isLikelyMp4File(file)) {
          debugPrint(
              'File already exists and is valid, skipping download: $savePath');
          return file;
        } else {
          // Delete corrupted file
          debugPrint('Deleting corrupted file: $savePath');
          await file.delete();
        }
      }

      debugPrint('Starting download: $videoUrl to $savePath');
      setState(() {
        _isDownloading = true;
        _downloadProgress = 0.0;
      });

      await _dio.download(
        videoUrl,
        savePath,
        deleteOnError: true, // Delete file if download fails
        options: Options(
          headers: _videoHttpHeaders,
          // Treat non-2xx responses as errors.
          validateStatus: (status) =>
              status != null && status >= 200 && status < 300,
          followRedirects: true,
        ),
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1 && mounted) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      // Verify the download completed successfully
      if (await file.exists()) {
        final fileSize = await file.length();
        debugPrint('Download completed: $savePath (Size: $fileSize bytes)');

        if (fileSize > 1024 && await _isLikelyMp4File(file)) {
          if (mounted) {
            setState(() {
              _isDownloading = false;
              _downloadProgress = 0.0;
            });
          }
          return file;
        } else {
          debugPrint('Downloaded file looks invalid, deleting');
          await file.delete();
        }
      }

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadProgress = 0.0;
        });
      }
      return null;
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        debugPrint('Download cancelled');
        return null;
      }

      debugPrint('Error downloading video: $e');
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadProgress = 0.0;
        });
      }
      return null;
    } catch (e) {
      debugPrint('Error downloading video: $e');
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadProgress = 0.0;
        });
      }
      return null;
    } finally {
      if (identical(_activeDownloadCancelToken, cancelToken)) {
        _activeDownloadCancelToken = null;
      }
    }
  }

  Future<File?> _prefetchVideo(String videoUrl) async {
    // If already prefetching this exact URL, reuse the same future.
    if (_prefetchUrl == videoUrl && _prefetchFuture != null) {
      return _prefetchFuture;
    }

    // Cancel any in-flight prefetch for a different URL.
    _cancelPrefetch();

    // If it is already cached (and valid), no need to prefetch.
    final cached = await _getCachedVideo(videoUrl);
    if (cached != null) return cached;

    final cancelToken = CancelToken();
    _prefetchCancelToken = cancelToken;
    _prefetchUrl = videoUrl;

    final future = _downloadAndCacheVideoSilently(
      videoUrl,
      cancelToken: cancelToken,
    );
    _prefetchFuture = future;
    return future;
  }

  Future<File?> _downloadAndCacheVideoSilently(
    String videoUrl, {
    required CancelToken cancelToken,
  }) async {
    try {
      final path = await _localPath;
      final fileName = _getVideoFileName(videoUrl);
      final savePath = '$path/$fileName';
      final file = File(savePath);

      if (await file.exists()) {
        final fileSize = await file.length();
        if (fileSize > 1024 && await _isLikelyMp4File(file)) {
          return file;
        }
        await file.delete();
      }

      await _dio.download(
        videoUrl,
        savePath,
        deleteOnError: true,
        options: Options(
          headers: _videoHttpHeaders,
          validateStatus: (status) =>
              status != null && status >= 200 && status < 300,
          followRedirects: true,
        ),
        cancelToken: cancelToken,
      );

      if (!await file.exists()) return null;
      final fileSize = await file.length();
      if (fileSize > 1024 && await _isLikelyMp4File(file)) {
        return file;
      }

      await file.delete();
      return null;
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) return null;
      return null;
    } catch (_) {
      return null;
    } finally {
      if (identical(_prefetchCancelToken, cancelToken)) {
        _prefetchCancelToken = null;
        _prefetchUrl = null;
        _prefetchFuture = null;
      }
    }
  }

  void _prefetchNextAfterStart(int index) {
    final nextIndex = index + 1;
    if (nextIndex >= 0 && nextIndex < wuduSteps.length) {
      final nextUrl = wuduSteps[nextIndex].videoPath;
      // Fire-and-forget prefetch; do not block playback.
      _prefetchVideo(nextUrl);
    } else {
      _cancelPrefetch();
    }
  }

  Future<void> _initializeVideo(int index) async {
    // If the user navigated mid-download, stop the current download.
    _cancelActiveDownload();

    // Dispose previous controller
    await _currentVideoController?.dispose();

    setState(() {
      _isVideoInitialized = false;
      _isVideoCompleted = false;
    });

    final videoPath = wuduSteps[index].videoPath;
    debugPrint('=== Initializing video for step $index ===');
    debugPrint('Video URL: $videoPath');

    try {
      // Check if video is cached
      File? cachedVideo = await _getCachedVideo(videoPath);

      VideoPlayerController controller;
      bool usedCache = false;

      if (cachedVideo != null) {
        usedCache = true;
        debugPrint('✓ Using cached video: ${cachedVideo.path}');
        controller = VideoPlayerController.file(cachedVideo);
      } else {
        debugPrint('✗ Video not in cache, will download: $videoPath');
        // If a prefetch for this URL is in-flight, await it to avoid duplicate
        // downloads and file write races.
        if (_prefetchUrl == videoPath && _prefetchFuture != null) {
          debugPrint('⏳ Awaiting prefetched video: $videoPath');
          cachedVideo = await _prefetchFuture;
        }

        // Download and cache the video if prefetch didn't produce a valid file.
        cachedVideo ??= await _downloadAndCacheVideo(videoPath);

        if (cachedVideo != null) {
          debugPrint('✓ Video downloaded and cached: ${cachedVideo.path}');
          controller = VideoPlayerController.file(cachedVideo);
        } else {
          // Fallback to network streaming if caching fails
          debugPrint('⚠ Caching failed, streaming from network');
          controller = VideoPlayerController.networkUrl(
            Uri.parse(videoPath),
            httpHeaders: _videoHttpHeaders,
          );
        }
      }

      // First initialization attempt.
      try {
        await controller.initialize();
      } catch (e) {
        debugPrint('Video initialize failed: $e');

        // If cached file fails on iOS (often due to HTML/partial/corrupt download),
        // delete cache and retry via re-download -> network fallback.
        if (usedCache && cachedVideo != null) {
          try {
            await cachedVideo.delete();
            debugPrint(
                'Deleted cached file after init failure: ${cachedVideo.path}');
          } catch (_) {}
        }

        await controller.dispose();

        // Retry once: attempt a fresh download; if that fails, stream.
        final freshFile = await _downloadAndCacheVideo(videoPath);
        if (freshFile != null) {
          controller = VideoPlayerController.file(freshFile);
        } else {
          controller = VideoPlayerController.networkUrl(
            Uri.parse(videoPath),
            httpHeaders: _videoHttpHeaders,
          );
        }

        await controller.initialize();
      }

      _currentVideoController = controller;

      // Add listener for video completion
      _currentVideoController!.addListener(() {
        if (_currentVideoController!.value.position ==
            _currentVideoController!.value.duration) {
          if (!_isVideoCompleted) {
            setState(() {
              _isVideoCompleted = true;
            });
            // Auto-advance to next slide after video completion
            _autoAdvanceToNext();
          }
        }
      });

      if (!mounted) return;
      setState(() {
        _isVideoInitialized = true;
      });

      // Auto-play the video
      _currentVideoController!.play();

      // Preload the next step while the current one plays.
      _prefetchNextAfterStart(index);
    } catch (e) {
      debugPrint('Error loading video: $e');
      // If video fails to load, show error and allow manual navigation
      if (!mounted) return;
      setState(() {
        _isVideoInitialized = false;
      });
    }
  }

  void _autoAdvanceToNext() {
    // Wait a bit before advancing to next slide
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_currentStepIndex < wuduSteps.length - 1) {
        _goToNextSlide();
      }
    });
  }

  void _goToNextSlide() {
    if (_currentStepIndex < wuduSteps.length - 1) {
      _cancelActiveDownload();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousSlide() {
    if (_currentStepIndex > 0) {
      _cancelActiveDownload();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Wudu Guide',
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
          // Topic Header
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
                        '${wuduSteps.length} steps',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Main Content Area
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  // Dots Indicator at Top
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        wuduSteps.length,
                        (index) => _buildDotIndicator(index),
                      ),
                    ),
                  ),

                  // Video Player and Content
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics:
                          const NeverScrollableScrollPhysics(), // Disable manual swipe
                      onPageChanged: (index) {
                        _cancelActiveDownload();
                        setState(() {
                          _currentStepIndex = index;
                        });
                        _initializeVideo(index);
                      },
                      itemCount: wuduSteps.length,
                      itemBuilder: (context, index) {
                        final item = wuduSteps[index];
                        return _buildStepContent(item);
                      },
                    ),
                  ),

                  // Navigation Buttons
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Previous Button
                        ElevatedButton.icon(
                          onPressed:
                              _currentStepIndex > 0 ? _goToPreviousSlide : null,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Previous'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B5E20),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[300],
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),

                        // Step Counter
                        Text(
                          '${_currentStepIndex + 1} / ${wuduSteps.length}',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1B5E20),
                          ),
                        ),

                        // Next Button
                        ElevatedButton.icon(
                          onPressed: _currentStepIndex < wuduSteps.length - 1
                              ? _goToNextSlide
                              : null,
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Next'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B5E20),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[300],
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildStepContent(WuduSliderItem item) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Video Player
          Container(
            width: double.infinity,
            height: 250,
            color: Colors.black,
            child: _isDownloading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF1B5E20),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Downloading video...',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 200,
                          child: LinearProgressIndicator(
                            value: _downloadProgress,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF1B5E20),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(_downloadProgress * 100).toStringAsFixed(0)}%',
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : _isVideoInitialized && _currentVideoController != null
                    ? AspectRatio(
                        aspectRatio: _currentVideoController!.value.aspectRatio,
                        child: VideoPlayer(_currentVideoController!),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF1B5E20),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading video...',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
          ),

          // Video Controls
          if (_isVideoInitialized && _currentVideoController != null)
            Container(
              color: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _currentVideoController!.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_currentVideoController!.value.isPlaying) {
                          _currentVideoController!.pause();
                        } else {
                          _currentVideoController!.play();
                        }
                      });
                    },
                  ),
                  Expanded(
                    child: VideoProgressIndicator(
                      _currentVideoController!,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: Color(0xFF1B5E20),
                        backgroundColor: Colors.white24,
                        bufferedColor: Colors.white54,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.replay, color: Colors.white),
                    onPressed: () {
                      _currentVideoController!.seekTo(Duration.zero);
                      _currentVideoController!.play();
                      setState(() {
                        _isVideoCompleted = false;
                      });
                    },
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Step Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              item.title,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B5E20),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 16),

          // Description in 3 Languages
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Arabic
                _buildLanguageCard('Arabic', item.arabic, Colors.blue[50]!,
                    Icons.book, TextAlign.right),
                const SizedBox(height: 12),

                // Urdu
                _buildLanguageCard('Urdu', item.urdu, Colors.orange[50]!,
                    Icons.translate, TextAlign.right),
                const SizedBox(height: 12),

                // English
                _buildLanguageCard('English', item.english, Colors.green[50]!,
                    Icons.language, TextAlign.left),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Verses Section
          if (item.verses != null && item.verses!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 4),
                  ...item.verses!.map((verse) {
                    if (verse.isEmpty) return const SizedBox.shrink();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF1B5E20).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        verse,
                        style: GoogleFonts.amiri(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          height: 1.8,
                        ),
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLanguageCard(
    String language,
    String text,
    Color backgroundColor,
    IconData icon,
    TextAlign textAlign,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1B5E20).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            text,
            style: GoogleFonts.amiri(
              fontSize: 15,
              height: 1.5,
              color: Colors.black87,
            ),
            textAlign: textAlign,
          )
        ],
      ),
    );
  }

  Widget _buildDotIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentStepIndex == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentStepIndex == index
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

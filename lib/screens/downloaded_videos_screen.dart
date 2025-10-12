import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../models/topic.dart';
import '../services/app_localizations.dart';
import '../services/offline_video_service.dart';
import 'video_player_screen.dart';

class DownloadedVideosScreen extends StatefulWidget {
  const DownloadedVideosScreen({super.key});

  @override
  State<DownloadedVideosScreen> createState() => _DownloadedVideosScreenState();
}

class _DownloadedVideosScreenState extends State<DownloadedVideosScreen> {
  final OfflineVideoService _offlineService = OfflineVideoService.instance;
  List<Lesson> _downloadedLessons = [];
  bool _isLoading = true;
  String _totalSize = '0 B';

  @override
  void initState() {
    super.initState();
    _loadDownloadedVideos();
  }

  @override
  void didUpdateWidget(DownloadedVideosScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh downloads when the widget updates
    _loadDownloadedVideos();
  }

  Future<void> _loadDownloadedVideos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Clean up any corrupted downloads first
      await _offlineService.cleanupCorruptedDownloads();

      final lessons = await _offlineService.getDownloadedLessons();
      final totalSizeBytes = await _offlineService.getTotalDownloadedSize();

      if (mounted) {
        setState(() {
          _downloadedLessons = lessons;
          _totalSize = OfflineVideoService.formatFileSize(totalSizeBytes);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading downloaded videos: $e');
      if (mounted) {
        setState(() {
          _downloadedLessons = [];
          _totalSize = '0 B';
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load downloaded videos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _refreshDownloads() async {
    await _loadDownloadedVideos();
  }

  Future<void> _deleteLesson(Lesson lesson) async {
    final localizations = AppLocalizations.of(context);

    // Show confirmation dialog
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

      if (success) {
        await _refreshDownloads(); // Refresh the list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.videoDeletedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.failedToDeleteVideo),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _clearAllDownloads() async {
    final localizations = AppLocalizations.of(context);

    if (_downloadedLessons.isEmpty) return;

    // Show confirmation dialog
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.clearAllDownloads),
        content: Text(localizations.clearAllDownloadsConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(localizations.clearAll),
          ),
        ],
      ),
    );

    if (shouldClear == true) {
      await _offlineService.clearAllDownloads();
      await _refreshDownloads(); // Refresh the list

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.allDownloadsClearedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _verifyDownloads() async {
    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Verifying Downloads'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Checking download integrity...',
              style: GoogleFonts.inter(fontSize: 14),
            ),
          ],
        ),
      ),
    );

    try {
      await _offlineService.cleanupCorruptedDownloads();
      await _refreshDownloads();

      if (mounted) {
        Navigator.of(context).pop(); // Close progress dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Download verification completed. ${_downloadedLessons.length} valid downloads found.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close progress dialog

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return VisibilityDetector(
      key: const Key('downloaded-videos-screen'),
      onVisibilityChanged: (VisibilityInfo info) {
        // Refresh when screen becomes visible
        if (info.visibleFraction > 0.5) {
          _refreshDownloads();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          title: Text(
            localizations.downloadedVideos,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshDownloads,
              tooltip: 'Refresh downloads',
            ),
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'verify') {
                  await _verifyDownloads();
                } else if (value == 'clear_all') {
                  await _clearAllDownloads();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'verify',
                  child: Row(
                    children: [
                      Icon(Icons.verified_user, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Verify Downloads'),
                    ],
                  ),
                ),
                if (_downloadedLessons.isNotEmpty)
                  PopupMenuItem(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_sweep, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(localizations.clearAllDownloads),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _refreshDownloads,
          color: const Color(0xFF23514C),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF23514C),
                  ),
                )
              : _downloadedLessons.isEmpty
                  ? _buildEmptyState(localizations)
                  : _buildDownloadsList(localizations),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations localizations) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.download_outlined,
                size: 80,
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                localizations.noDownloadedVideos,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                localizations.downloadVideosForOfflineViewing,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Pull down to refresh',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadsList(AppLocalizations localizations) {
    return Column(
      children: [
        // Storage info
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.storage,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.storageUsed,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    Text(
                      _totalSize,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${_downloadedLessons.length} ${localizations.videos}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),

        // Downloaded videos list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _downloadedLessons.length,
            itemBuilder: (context, index) {
              final lesson = _downloadedLessons[index];
              return _buildLessonCard(lesson, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLessonCard(Lesson lesson, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                relatedLessons: _downloadedLessons,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (lesson.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        lesson.description,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.download_done,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppLocalizations.of(context).downloaded,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (lesson.duration != '00:00') ...[
                          const SizedBox(width: 16),
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            lesson.duration,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteLesson(lesson);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context).delete),
                      ],
                    ),
                  ),
                ],
                child: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

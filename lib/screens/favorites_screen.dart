import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../models/topic.dart';
import '../services/app_localizations.dart';
import '../services/favorites_service.dart';
import 'video_player_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Lesson> _favoriteLessons = [];
  bool _isLoading = true;
  final FavoritesService _favoritesService = FavoritesService.instance;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void didUpdateWidget(FavoritesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh favorites when the widget updates
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final favorites = await _favoritesService.getFavorites();
      if (mounted) {
        setState(() {
          _favoriteLessons = favorites;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading favorites: $e');
      if (mounted) {
        setState(() {
          _favoriteLessons = [];
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).failedToUpdateFavorites),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _refreshFavorites() async {
    await _loadFavorites();
  }

  void _removeFavorite(String lessonId) async {
    final success = await _favoritesService.removeFromFavorites(lessonId);
    if (success) {
      // Refresh the entire list to ensure data consistency
      await _refreshFavorites();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).removedFromFavorites),
            backgroundColor: const Color(0xFF23514C),
          ),
        );
      }
    }
  }

  void _clearAllFavorites() async {
    // Show confirmation dialog
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).clearAllFavorites),
        content: Text(AppLocalizations.of(context).clearAllFavoritesConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context).clear),
          ),
        ],
      ),
    );

    if (shouldClear == true) {
      final success = await _favoritesService.clearFavorites();
      if (success) {
        // Refresh the entire list to ensure data consistency
        await _refreshFavorites();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).allFavoritesCleared),
              backgroundColor: const Color(0xFF23514C),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return VisibilityDetector(
      key: const Key('favorites-screen'),
      onVisibilityChanged: (VisibilityInfo info) {
        // Refresh when screen becomes visible
        if (info.visibleFraction > 0.5) {
          _refreshFavorites();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            localizations.favorites,
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF23514C),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshFavorites,
              tooltip: 'Refresh favorites',
            ),
            if (_favoriteLessons.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear_all),
                onPressed: _clearAllFavorites,
                tooltip: 'Clear all favorites',
              ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _refreshFavorites,
          color: const Color(0xFF23514C),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF23514C),
                  ),
                )
              : _favoriteLessons.isEmpty
                  ? _buildEmptyState()
                  : _buildFavoritesList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_outline,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No Favorites Yet',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your favorite lessons will appear here',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pull down to refresh',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Navigate to topics screen
                  DefaultTabController.of(context).animateTo(1);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF23514C),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Explore Topics'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesList() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.favorite,
                color: Colors.red[400],
              ),
              const SizedBox(width: 8),
              Text(
                '${_favoriteLessons.length} Favorite Lessons',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),

        // Favorites List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _favoriteLessons.length,
            itemBuilder: (context, index) {
              final lesson = _favoriteLessons[index];
              return _buildFavoriteCard(lesson);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteCard(Lesson lesson) {
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
                relatedLessons: _favoriteLessons,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Thumbnail with better image handling
              Container(
                width: 80,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: lesson.thumbnailUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: lesson.thumbnailUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
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
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
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
                            child: const Icon(
                              Icons.video_library,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Container(
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
                          child: const Icon(
                            Icons.play_circle_outline,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(width: 16),

              // Lesson Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lesson.description,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[600],
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
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lesson.duration,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.format_list_numbered,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Lesson ${lesson.lessonNumber}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Column(
                children: [
                  IconButton(
                    onPressed: () => _removeFavorite(lesson.id),
                    icon: Icon(
                      Icons.favorite,
                      color: Colors.red[400],
                    ),
                    tooltip: 'Remove from favorites',
                  ),
                  if (lesson.referenceFileUrl != null &&
                      lesson.referenceFileUrl!.isNotEmpty)
                    IconButton(
                      onPressed: () => _downloadReference(lesson),
                      icon: Icon(
                        Icons.download,
                        color: Colors.blue[600],
                      ),
                      tooltip: 'Download reference',
                    ),
                  IconButton(
                    onPressed: () => _shareLesson(lesson),
                    icon: Icon(
                      Icons.share,
                      color: Colors.grey[600],
                    ),
                    tooltip: 'Share lesson',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareLesson(Lesson lesson) {
    // In a real app, you would use share_plus package
    // For now, we'll show a dialog with lesson details that could be copied
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Lesson'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lesson.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Duration: ${lesson.duration}'),
            Text('Lesson: ${lesson.lessonNumber}'),
            const SizedBox(height: 8),
            Text(lesson.description),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lesson details copied: ${lesson.title}'),
                  backgroundColor: const Color(0xFF23514C),
                ),
              );
            },
            child: const Text('Copy'),
          ),
        ],
      ),
    );
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
      final Uri url = Uri.parse(lesson.referenceFileUrl!);

      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication, // Open in external browser/app
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening reference material: ${lesson.title}'),
              backgroundColor: const Color(0xFF23514C),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cannot open reference material'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error launching URL: $e');
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
}

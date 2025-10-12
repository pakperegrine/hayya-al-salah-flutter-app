import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/topic.dart';

class OfflineVideoService {
  static final OfflineVideoService _instance = OfflineVideoService._internal();
  static OfflineVideoService get instance => _instance;
  OfflineVideoService._internal();

  final Dio _dio = Dio();
  final String _downloadedVideosKey = 'downloaded_videos';

  /// Get the downloads directory for storing offline videos
  Future<Directory> _getDownloadsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final downloadsDir = Directory('${appDir.path}/offline_videos');
    if (!downloadsDir.existsSync()) {
      downloadsDir.createSync(recursive: true);
    }
    return downloadsDir;
  }

  /// Get metadata file for storing download information
  Future<File> _getMetadataFile() async {
    final downloadsDir = await _getDownloadsDirectory();
    return File('${downloadsDir.path}/metadata.json');
  }

  /// Get local file path for a lesson video
  Future<String> _getVideoFilePath(String lessonId) async {
    final downloadsDir = await _getDownloadsDirectory();
    return '${downloadsDir.path}/lesson_$lessonId.mp4';
  }

  /// Check if a lesson is downloaded
  Future<bool> isLessonDownloaded(String lessonId) async {
    try {
      final filePath = await _getVideoFilePath(lessonId);
      final file = File(filePath);
      return file.existsSync();
    } catch (e) {
      return false;
    }
  }

  /// Get local video file path if downloaded
  Future<String?> getLocalVideoPath(String lessonId) async {
    if (await isLessonDownloaded(lessonId)) {
      return await _getVideoFilePath(lessonId);
    }
    return null;
  }

  /// Download a lesson video for offline viewing
  Future<bool> downloadLesson(
    Lesson lesson, {
    Function(double)? onProgress,
    Function(String)? onError,
  }) async {
    try {
      if (lesson.videoUrl.isEmpty) {
        onError?.call('Video URL is empty');
        return false;
      }

      final filePath = await _getVideoFilePath(lesson.id);
      final file = File(filePath);

      // Check if already downloaded
      if (file.existsSync()) {
        return true;
      }

      // Download the video
      await _dio.download(
        lesson.videoUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            onProgress?.call(progress);
          }
        },
      );

      // Save lesson metadata
      await _saveDownloadedLessonMetadata(lesson);

      return true;
    } catch (e) {
      onError?.call('Download failed: $e');
      return false;
    }
  }

  /// Save lesson metadata for downloaded video
  Future<void> _saveDownloadedLessonMetadata(Lesson lesson) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing metadata
      final existingData = prefs.getString(_downloadedVideosKey) ?? '[]';
      List<dynamic> lessonsList = [];

      try {
        lessonsList = json.decode(existingData);
      } catch (e) {
        lessonsList = [];
      }

      // Remove existing entry if present
      lessonsList.removeWhere((item) => item['id'] == lesson.id);

      // Add new lesson metadata
      lessonsList.add({
        'id': lesson.id,
        'title': lesson.title,
        'description': lesson.description,
        'videoUrl': lesson.videoUrl,
        'thumbnailUrl': lesson.thumbnailUrl,
        'duration': lesson.duration,
        'lessonNumber': lesson.lessonNumber,
        'referenceFileUrl': lesson.referenceFileUrl,
        'downloadedAt': DateTime.now().millisecondsSinceEpoch,
      });

      // Save to SharedPreferences
      await prefs.setString(_downloadedVideosKey, json.encode(lessonsList));
    } catch (e) {
      print('Error saving lesson metadata: $e');
    }
  }

  /// Get list of downloaded lessons
  Future<List<Lesson>> getDownloadedLessons() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_downloadedVideosKey) ?? '[]';

      if (data.isEmpty || data == '[]') {
        return [];
      }

      List<dynamic> lessonsList = [];
      try {
        lessonsList = json.decode(data);
      } catch (e) {
        print('Error parsing lesson metadata: $e');
        return [];
      }

      final lessons = <Lesson>[];
      for (final item in lessonsList) {
        try {
          final lessonId = item['id']?.toString() ?? '';
          if (lessonId.isNotEmpty && await isLessonDownloaded(lessonId)) {
            final localPath = await _getVideoFilePath(lessonId);
            lessons.add(Lesson(
              id: lessonId,
              title: item['title']?.toString() ?? 'Downloaded Lesson $lessonId',
              description: item['description']?.toString() ?? 'Offline lesson',
              videoUrl: localPath, // Use local path for offline playback
              thumbnailUrl: item['thumbnailUrl']?.toString() ?? '',
              duration: item['duration']?.toString() ?? '00:00',
              lessonNumber: item['lessonNumber'] ?? 1,
              referenceFileUrl: item['referenceFileUrl']?.toString(),
            ));
          }
        } catch (e) {
          print('Error processing lesson item: $e');
          continue;
        }
      }

      return lessons;
    } catch (e) {
      print('Error getting downloaded lessons: $e');
      return [];
    }
  }

  /// Delete a downloaded lesson
  Future<bool> deleteDownloadedLesson(String lessonId) async {
    try {
      final filePath = await _getVideoFilePath(lessonId);
      final file = File(filePath);

      if (file.existsSync()) {
        await file.delete();
      }

      // Remove from metadata
      await _removeDownloadedLessonMetadata(lessonId);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Remove lesson metadata for deleted video
  Future<void> _removeDownloadedLessonMetadata(String lessonId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_downloadedVideosKey) ?? '[]';

      List<dynamic> lessonsList = [];
      try {
        lessonsList = json.decode(data);
      } catch (e) {
        lessonsList = [];
      }

      // Remove the lesson with the specified ID
      lessonsList.removeWhere((item) => item['id'] == lessonId);

      // Save updated list
      await prefs.setString(_downloadedVideosKey, json.encode(lessonsList));
    } catch (e) {
      print('Error removing lesson metadata: $e');
    }
  }

  /// Get total size of downloaded videos
  Future<int> getTotalDownloadedSize() async {
    try {
      final downloadsDir = await _getDownloadsDirectory();
      int totalSize = 0;

      if (downloadsDir.existsSync()) {
        final files = downloadsDir.listSync();
        for (final file in files) {
          if (file is File && file.path.endsWith('.mp4')) {
            totalSize += file.lengthSync();
          }
        }
      }

      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Clear all downloaded videos
  Future<void> clearAllDownloads() async {
    try {
      final downloadsDir = await _getDownloadsDirectory();

      if (downloadsDir.existsSync()) {
        await downloadsDir.delete(recursive: true);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_downloadedVideosKey);
    } catch (e) {
      print('Error clearing downloads: $e');
    }
  }

  /// Format file size for display
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB'];
    final i = (bytes.bitLength - 1) ~/ 10;
    final size = bytes / (1 << (i * 10));

    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }

  /// Check available storage space
  Future<int> getAvailableSpace() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final stat = directory.statSync();
      return stat.size;
    } catch (e) {
      return 0;
    }
  }

  /// Clean up corrupted downloads and orphaned metadata
  Future<void> cleanupCorruptedDownloads() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_downloadedVideosKey) ?? '[]';

      List<dynamic> lessonsList = [];
      try {
        lessonsList = json.decode(data);
      } catch (e) {
        // If metadata is corrupted, clear it
        await prefs.setString(_downloadedVideosKey, '[]');
        return;
      }

      final validLessons = <dynamic>[];

      for (final item in lessonsList) {
        final lessonId = item['id']?.toString() ?? '';
        if (lessonId.isNotEmpty) {
          final filePath = await _getVideoFilePath(lessonId);
          final file = File(filePath);

          // Check if file exists and has reasonable size (> 1KB)
          if (file.existsSync() && file.lengthSync() > 1024) {
            validLessons.add(item);
          } else {
            print('Removing corrupted/missing download: $lessonId');
            // Clean up the file if it exists but is corrupted
            if (file.existsSync()) {
              try {
                await file.delete();
              } catch (e) {
                print('Error deleting corrupted file: $e');
              }
            }
          }
        }
      }

      // Save cleaned metadata
      await prefs.setString(_downloadedVideosKey, json.encode(validLessons));

      // Clean up orphaned files in download directory
      final downloadsDir = await _getDownloadsDirectory();
      if (downloadsDir.existsSync()) {
        final files = downloadsDir.listSync();
        for (final file in files) {
          if (file is File && file.path.endsWith('.mp4')) {
            final fileName = file.path.split('/').last;
            final lessonId =
                fileName.replaceAll('lesson_', '').replaceAll('.mp4', '');

            // Check if this file has metadata
            final hasMetadata =
                validLessons.any((item) => item['id'] == lessonId);
            if (!hasMetadata) {
              print('Removing orphaned file: ${file.path}');
              try {
                await file.delete();
              } catch (e) {
                print('Error deleting orphaned file: $e');
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error during cleanup: $e');
    }
  }
}

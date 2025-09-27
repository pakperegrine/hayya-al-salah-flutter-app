import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/notification.dart';
import '../services/api_service.dart';
import 'notification_detail_page.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<AppNotification> notifications = [];
  Set<String> localReadIds = {};
  bool loading = true;
  final ApiService _apiService = ApiService();

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
    loadData();
  }

  Future<void> loadData() async {
    setState(() => loading = true);
    await _loadLocalReadIds();
    await fetchNotifications();
    setState(() => loading = false);
  }

  Future<void> _loadLocalReadIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      localReadIds =
          (prefs.getStringList('read_notification_ids') ?? []).toSet();
    } catch (e) {
      print('Error loading local read IDs: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiService.initialize();
      final success = await _apiService.markNotificationAsRead(notificationId);
      if (success) {
        // Update local state
        setState(() {
          localReadIds.add(notificationId);
          final index = notifications.indexWhere((n) => n.id == notificationId);
          if (index != -1) {
            notifications[index] = notifications[index].copyWith(
              isRead: true,
              readAt: DateTime.now(),
            );
          }
        });
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> fetchNotifications() async {
    try {
      print('📡 Fetching notifications using ApiService...');
      await _apiService.initialize();

      // Fetch notifications using ApiService
      notifications = await _apiService.getNotifications();
      print('📦 Fetched ${notifications.length} notifications');

      // Sort notifications by timestamp, latest first
      notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      if (notifications.isEmpty) {
        print('📝 No notifications from API, using sample data');
        notifications = _getSampleNotifications();
      }
    } catch (e) {
      print('❌ Error fetching notifications: $e');
      // Use sample notifications instead of empty list
      notifications = _getSampleNotifications();
      print('📝 Using sample notifications due to error');
    }
  }

  List<AppNotification> _getSampleNotifications() {
    return [
      AppNotification(
        id: 'sample-1',
        title: 'Welcome to Hayya Al Salah!',
        message:
            'Thank you for downloading our app. Start your journey of learning prayer with our comprehensive lessons.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      AppNotification(
        id: 'sample-2',
        title: 'نیا سبق دستیاب ہے',
        message: 'نماز کے اوقات پر ایک نیا سبق شامل کیا گیا ہے۔ اسے اب دیکھیں!',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      AppNotification(
        id: 'sample-3',
        title: 'Prayer Reminder',
        message:
            'Don\'t forget to perform your daily prayers. Set up prayer time notifications for regular reminders.',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF23514C),
        foregroundColor: Colors.white,
        actions: [
          if (notifications
              .any((n) => !n.isRead && !localReadIds.contains(n.id)))
            IconButton(
              icon: const Icon(Icons.done_all),
              onPressed: () async {
                try {
                  await _apiService.markAllNotificationsAsRead();
                  setState(() {
                    for (final notification in notifications) {
                      localReadIds.add(notification.id);
                    }
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('All notifications marked as read')),
                    );
                  }
                } catch (e) {
                  print('Error marking all as read: $e');
                }
              },
              tooltip: 'Mark all as read',
            ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF23514C),
              ),
            )
          : notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pull down to refresh',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadData,
                  child: ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notif = notifications[index];
                      // Check read status from both backend and local storage
                      final isRead =
                          notif.isRead || localReadIds.contains(notif.id);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        elevation: 2,
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isRead
                                  ? Colors.grey.shade200
                                  : const Color(0xFF23514C).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Icon(
                              Icons.notifications,
                              color: isRead
                                  ? Colors.grey.shade600
                                  : const Color(0xFF23514C),
                              size: 20,
                            ),
                          ),
                          title: buildUnicodeText(
                            notif.title,
                            style: TextStyle(
                                fontWeight: isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold),
                          ),
                          subtitle: buildUnicodeText(
                            notif.message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                formatTimeAgo(notif.timestamp.toLocal()),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                              if (!isRead)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF23514C),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          onTap: () async {
                            // Check read status from both backend and local storage
                            final isAlreadyRead =
                                notif.isRead || localReadIds.contains(notif.id);

                            // Mark as read if not already read
                            if (!isAlreadyRead) {
                              await markAsRead(notif.id);
                            }

                            if (mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NotificationDetailPage(
                                    notification: notif,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

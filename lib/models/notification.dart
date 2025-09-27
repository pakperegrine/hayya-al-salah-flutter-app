class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final DateTime? readAt;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.readAt,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      // Handle missing read status fields gracefully
      isRead: json['is_read'] == 1 ||
          json['is_read'] == true ||
          json['is_read'] == '1',
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      userId: json['user_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    DateTime? readAt,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

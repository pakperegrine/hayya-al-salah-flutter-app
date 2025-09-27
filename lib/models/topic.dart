class Topic {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int lessonsCount;
  final String duration;
  final List<Lesson> lessons;

  Topic({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.lessonsCount,
    required this.duration,
    required this.lessons,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      lessonsCount: json['lessons_count'] ?? 0,
      duration: json['duration'] ?? '',
      lessons: (json['lessons'] as List<dynamic>?)
              ?.map((lessonJson) => Lesson.fromJson(lessonJson))
              .toList() ??
          [],
    );
  }

  // Factory constructor for API response format
  factory Topic.fromApiJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      lessonsCount: json['lessons_count'] ?? 0,
      duration: json['duration'] ?? '',
      lessons: (json['lessons'] as List<dynamic>?)
              ?.map((lessonJson) => Lesson.fromApiJson(lessonJson))
              .toList() ??
          [],
    );
  }
}

class Lesson {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String thumbnailUrl;
  final String duration;
  final int lessonNumber;
  final String? referenceFileUrl;
  final List<Lesson> relatedLessons;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.duration,
    required this.lessonNumber,
    this.referenceFileUrl,
    this.relatedLessons = const [],
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      videoUrl: json['video_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      duration: json['duration'] ?? '',
      lessonNumber: json['lesson_number'] ?? 0,
      referenceFileUrl: json['reference_file_url'],
      relatedLessons: (json['related_lessons'] as List<dynamic>?)
              ?.map((lessonJson) => Lesson.fromJson(lessonJson))
              .toList() ??
          [],
    );
  }

  // Factory constructor for API response format
  factory Lesson.fromApiJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      videoUrl: json['video_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      duration: json['duration'] ?? '',
      lessonNumber: json['lesson_number'] ?? 0,
      referenceFileUrl: json['reference_file_url'],
      relatedLessons: (json['related_lessons'] as List<dynamic>?)
              ?.map((lessonJson) => Lesson.fromApiJson(lessonJson))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'duration': duration,
      'lesson_number': lessonNumber,
      'reference_file_url': referenceFileUrl,
      'related_lessons':
          relatedLessons.map((lesson) => lesson.toJson()).toList(),
    };
  }
}

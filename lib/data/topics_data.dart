import '../models/topic.dart';
import 'prayer_steps_data.dart';

final List<Topic> topicsData = [
    Topic(
      id: '1',
      title: 'Salah Lessons',
      description: 'By Dr. Farhat Hashmi',
      imageUrl: 'https://example.com/images/prayer.jpg',
      lessonsCount: 67,
      duration: '9:09:22',
      action: 'lectures',
      lessons: [],
    ),
    Topic(
      id: '2',
      title: 'Salah Guide',
      description: 'Step by Step Salah Guide',
      imageUrl: 'https://example.com/images/quran.jpg',
      lessonsCount: prayerSteps.length,
      duration: '0:00',
      action: 'prayer',
      lessons: [],
    ),
    Topic(
      id: '3',
      title: 'Wazu Guide',
      description: 'Step by Step Wazu Guide',
      imageUrl: 'https://example.com/images/quran.jpg',
      lessonsCount: 0,
      duration: '0:00',
      action: 'wazu',
      lessons: [],
    ),
  ];

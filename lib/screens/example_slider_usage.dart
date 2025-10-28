// Example usage of LessonDetailSliderScreen
// 
// This file demonstrates how to use the new LessonDetailSliderScreen
// which includes an SVG slider with text descriptions below.
//
// Key Features:
// 1. Auto-sliding SVG carousel with 5 different educational features
// 2. Each slide has an SVG icon, title, and description
// 3. Dot indicators to show current slide position
// 4. Enhanced lesson cards with SVG icons
// 5. Gradient backgrounds and modern UI design
//
// To use this screen instead of the original LessonDetailScreen:
//
// Replace in home_screen.dart:
// OLD:
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => LessonDetailScreen(topic: topic),
//     ),
//   );
//
// NEW:
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => LessonDetailSliderScreen(topic: topic),
//     ),
//   );
//
// Replace in topics_screen.dart:
// OLD:
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => LessonDetailScreen(topic: topic),
//     ),
//   );
//
// NEW:
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => LessonDetailSliderScreen(topic: topic),
//     ),
//   );
//
// Don't forget to import the new screen:
// import '../screens/lesson_detail_slider_screen.dart';

import 'package:flutter/material.dart';
import '../models/topic.dart';


class ExampleSliderUsage extends StatelessWidget {
  const ExampleSliderUsage({super.key});

  @override
  Widget build(BuildContext context) {
    // Example topic for demonstration
    final exampleTopic = Topic(
      id: '1',
      title: 'Prayer Basics',
      description: 'Learn the fundamental aspects of Islamic prayer',
      lessonsCount: 8,
      duration: '2h 30m',
      imageUrl: '',
      action: 'Start Learning',
      lessons: [], // Empty list for demonstration
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Slider Demo'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            
          },
          child: const Text('Open Lesson Detail with Slider'),
        ),
      ),
    );
  }
}
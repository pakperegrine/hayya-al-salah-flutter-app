
// Data model for slider items
class PrayerSliderItem {
  final String svgPath;
  final String title;
  final String urdu;
  final String arabic;
  final String english;
  final String banner;
  final String audio;
  final String action;
  final List<String>? verses;

  PrayerSliderItem({
    required this.svgPath,
    required this.title,
    required this.urdu,
    required this.arabic,
    required this.english,
    required this.banner,
    required this.audio,
    required this.action,
    this.verses,
  });
}
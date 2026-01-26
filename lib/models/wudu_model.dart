// Data model for wudu slider items
class WuduSliderItem {
  final String videoPath;
  final String title;
  final String urdu;
  final String arabic;
  final String english;
  final String banner;
  final String action;
  final List<String>? verses;

  WuduSliderItem({
    required this.videoPath,
    required this.title,
    required this.urdu,
    required this.arabic,
    required this.english,
    required this.banner,
    required this.action,
    this.verses,
  });
}

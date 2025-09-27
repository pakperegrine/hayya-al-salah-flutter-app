class QuranVerse {
  final int surah;
  final int ayah;
  final String arabicText;
  final String englishTranslation;
  final String urduTranslation;
  final String surahName;
  final String surahNameEnglish;

  QuranVerse({
    required this.surah,
    required this.ayah,
    required this.arabicText,
    required this.englishTranslation,
    required this.urduTranslation,
    required this.surahName,
    required this.surahNameEnglish,
  });

  factory QuranVerse.fromJson(Map<String, dynamic> json) {
    return QuranVerse(
      surah: json['surah'] ?? 0,
      ayah: json['ayah'] ?? 0,
      arabicText: json['text'] ?? '',
      englishTranslation: json['translation_en'] ?? '',
      urduTranslation: json['translation_ur'] ?? '',
      surahName: json['surah_name'] ?? '',
      surahNameEnglish: json['surah_name_en'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'surah': surah,
      'ayah': ayah,
      'text': arabicText,
      'translation_en': englishTranslation,
      'translation_ur': urduTranslation,
      'surah_name': surahName,
      'surah_name_en': surahNameEnglish,
    };
  }
}

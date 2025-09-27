import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/quran_verse.dart';

class QuranApiService {
  static const String baseUrl = 'http://api.alquran.cloud/v1';

  // Alternative API for more comprehensive data
  static const String altBaseUrl = 'https://api.quran.com/api/v4';

  /// Fetches a random Quranic verse with translations
  Future<QuranVerse?> getRandomVerse() async {
    try {
      // Generate random surah (1-114) and random ayah
      final random = Random();
      final randomSurah = random.nextInt(114) + 1;

      // First get surah info to know how many ayahs it has
      final surahInfoResponse = await http.get(
        Uri.parse('$baseUrl/surah/$randomSurah'),
      );

      if (surahInfoResponse.statusCode == 200) {
        final surahData = json.decode(surahInfoResponse.body);
        final ayahsCount = surahData['data']['ayahs'].length;
        final randomAyah = random.nextInt(ayahsCount) + 1;

        // Get the specific verse with Arabic text
        final arabicResponse = await http.get(
          Uri.parse('$baseUrl/ayah/$randomSurah:$randomAyah'),
        );

        // Get English translation
        final englishResponse = await http.get(
          Uri.parse('$baseUrl/ayah/$randomSurah:$randomAyah/en.sahih'),
        );

        // Get Urdu translation
        final urduResponse = await http.get(
          Uri.parse('$baseUrl/ayah/$randomSurah:$randomAyah/ur.jalandhry'),
        );

        if (arabicResponse.statusCode == 200 &&
            englishResponse.statusCode == 200 &&
            urduResponse.statusCode == 200) {
          final arabicData = json.decode(arabicResponse.body);
          final englishData = json.decode(englishResponse.body);
          final urduData = json.decode(urduResponse.body);

          return QuranVerse(
            surah: randomSurah,
            ayah: randomAyah,
            arabicText: arabicData['data']['text'] ?? '',
            englishTranslation: englishData['data']['text'] ?? '',
            urduTranslation: urduData['data']['text'] ?? '',
            surahName: arabicData['data']['surah']['name'] ?? '',
            surahNameEnglish: arabicData['data']['surah']['englishName'] ?? '',
          );
        }
      }

      // Fallback to a predefined verse if API fails
      return _getFallbackVerse();
    } catch (e) {
      print('Error fetching Quran verse: $e');
      return _getFallbackVerse();
    }
  }

  /// Fetches a specific verse by surah and ayah number
  Future<QuranVerse?> getVerse(int surah, int ayah) async {
    try {
      // Get Arabic text
      final arabicResponse = await http.get(
        Uri.parse('$baseUrl/ayah/$surah:$ayah'),
      );

      // Get English translation
      final englishResponse = await http.get(
        Uri.parse('$baseUrl/ayah/$surah:$ayah/en.sahih'),
      );

      // Get Urdu translation
      final urduResponse = await http.get(
        Uri.parse('$baseUrl/ayah/$surah:$ayah/ur.jalandhry'),
      );

      if (arabicResponse.statusCode == 200 &&
          englishResponse.statusCode == 200 &&
          urduResponse.statusCode == 200) {
        final arabicData = json.decode(arabicResponse.body);
        final englishData = json.decode(englishResponse.body);
        final urduData = json.decode(urduResponse.body);

        return QuranVerse(
          surah: surah,
          ayah: ayah,
          arabicText: arabicData['data']['text'] ?? '',
          englishTranslation: englishData['data']['text'] ?? '',
          urduTranslation: urduData['data']['text'] ?? '',
          surahName: arabicData['data']['surah']['name'] ?? '',
          surahNameEnglish: arabicData['data']['surah']['englishName'] ?? '',
        );
      }

      return null;
    } catch (e) {
      print('Error fetching specific verse: $e');
      return null;
    }
  }

  /// Fallback verse when API is unavailable
  QuranVerse _getFallbackVerse() {
    return QuranVerse(
      surah: 2,
      ayah: 255,
      arabicText:
          'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ',
      englishTranslation:
          'Allah - there is no deity except Him, the Ever-Living, the Sustainer of existence. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth.',
      urduTranslation:
          'اللہ کے علاوہ کوئی معبود نہیں، وہ زندہ اور قائم رکھنے والا ہے۔ اسے نہ اونگھ آتی ہے اور نہ نیند۔ آسمانوں اور زمین میں جو کچھ ہے سب اسی کا ہے۔',
      surahName: 'البقرة',
      surahNameEnglish: 'Al-Baqarah',
    );
  }
}

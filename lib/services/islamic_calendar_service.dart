import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

class IslamicCalendarService {
  /// Get current date in both Gregorian and Islamic calendar
  Map<String, String> getCurrentDate() {
    final now = DateTime.now();
    final hijriDate = HijriCalendar.fromDate(now);

    // Format Gregorian date
    final gregorianFormatter = DateFormat('EEEE, MMMM d, yyyy');
    final gregorianDate = gregorianFormatter.format(now);

    // Format Islamic date
    final islamicDate =
        '${hijriDate.hDay} ${_getIslamicMonthName(hijriDate.hMonth)}, ${hijriDate.hYear} AH';

    return {
      'gregorian': gregorianDate,
      'islamic': islamicDate,
      'dayName': DateFormat('EEEE').format(now),
    };
  }

  /// Get Islamic month name in English
  String _getIslamicMonthName(int month) {
    const months = [
      'Muharram',
      'Safar',
      'Rabi\' al-awwal',
      'Rabi\' al-thani',
      'Jumada al-awwal',
      'Jumada al-thani',
      'Rajab',
      'Sha\'ban',
      'Ramadan',
      'Shawwal',
      'Dhu al-Qi\'dah',
      'Dhu al-Hijjah',
    ];

    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return 'Unknown';
  }

  /// Get Islamic month name in Arabic
  String _getIslamicMonthNameArabic(int month) {
    const months = [
      'محرم',
      'صفر',
      'ربيع الأول',
      'ربيع الثاني',
      'جمادى الأولى',
      'جمادى الثانية',
      'رجب',
      'شعبان',
      'رمضان',
      'شوال',
      'ذو القعدة',
      'ذو الحجة',
    ];

    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return 'غير معروف';
  }

  /// Check if current month is Ramadan
  bool isRamadan() {
    final hijriDate = HijriCalendar.fromDate(DateTime.now());
    return hijriDate.hMonth == 9; // Ramadan is the 9th month
  }

  /// Get formatted Islamic date with Arabic month name
  String getIslamicDateArabic() {
    final hijriDate = HijriCalendar.fromDate(DateTime.now());
    return '${hijriDate.hDay} ${_getIslamicMonthNameArabic(hijriDate.hMonth)} ${hijriDate.hYear} هـ';
  }
}

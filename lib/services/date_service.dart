import 'package:hijri/hijri_calendar.dart';

const _gregorianWeekdays = {
  'ar': ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'],
  'en': ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
};

const _gregorianMonths = {
  'ar': [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ],
  'en': [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ],
};

/// Formats today's Gregorian date, e.g. "الأربعاء 5 أغسطس 2026".
String formatGregorian(DateTime date, String lang) {
  final weekday = _gregorianWeekdays[lang]![date.weekday - 1];
  final month = _gregorianMonths[lang]![date.month - 1];
  return '$weekday ${date.day} $month ${date.year}';
}

/// Formats today's Hijri date, e.g. "٢١ صفر ١٤٤٨هـ" (ar) / "21 Safar 1448 AH" (en).
String formatHijri(DateTime date, String lang) {
  HijriCalendar.language = lang == 'ar' ? 'ar' : 'en';
  final hijri = HijriCalendar.fromDate(date);
  final suffix = lang == 'ar' ? 'هـ' : ' AH';
  return '${hijri.hDay} ${hijri.getLongMonthName()} ${hijri.hYear}$suffix';
}

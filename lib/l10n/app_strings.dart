import 'package:flutter/widgets.dart';

/// Lightweight hand-rolled translation table (no codegen) for the two
/// supported locales. Kept intentionally simple for a small single-purpose app.
class AppStrings {
  static const Map<String, Map<String, String>> _values = {
    'appName': {'ar': 'مواقيت الصلاة والقبلة', 'en': 'Prayer Times & Qibla'},
    'tabPrayerTimes': {'ar': 'المواقيت', 'en': 'Prayers'},
    'tabQibla': {'ar': 'القبلة', 'en': 'Qibla'},
    'tabSettings': {'ar': 'الإعدادات', 'en': 'Settings'},
    'fajr': {'ar': 'الفجر', 'en': 'Fajr'},
    'sunrise': {'ar': 'الشروق', 'en': 'Sunrise'},
    'dhuhr': {'ar': 'الظهر', 'en': 'Dhuhr'},
    'asr': {'ar': 'العصر', 'en': 'Asr'},
    'maghrib': {'ar': 'المغرب', 'en': 'Maghrib'},
    'isha': {'ar': 'العشاء', 'en': 'Isha'},
    'nextPrayer': {'ar': 'الصلاة القادمة', 'en': 'Next prayer'},
    'locating': {'ar': 'جاري تحديد الموقع...', 'en': 'Locating...'},
    'locationDenied': {
      'ar': 'محتاجين إذن الموقع لحساب المواقيت بدقة',
      'en': 'Location permission is needed for accurate prayer times',
    },
    'grantPermission': {'ar': 'السماح بالوصول للموقع', 'en': 'Grant location access'},
    'retry': {'ar': 'إعادة المحاولة', 'en': 'Retry'},
    'qiblaTitle': {'ar': 'اتجاه القبلة', 'en': 'Qibla direction'},
    'qiblaHint': {
      'ar': 'ضع الهاتف مسطحاً وحرّكه حتى يتجه المؤشر لأعلى',
      'en': 'Lay the phone flat and rotate until the arrow points up',
    },
    'compassUnavailable': {
      'ar': 'جهازك لا يحتوي على حساس بوصلة',
      'en': 'Your device has no compass sensor',
    },
    'calculationMethod': {'ar': 'طريقة الحساب', 'en': 'Calculation method'},
    'madhab': {'ar': 'المذهب (لحساب العصر)', 'en': 'Madhab (Asr calculation)'},
    'shafi': {'ar': 'شافعي وغيره', 'en': 'Shafi (and others)'},
    'hanafi': {'ar': 'حنفي', 'en': 'Hanafi'},
    'language': {'ar': 'اللغة', 'en': 'Language'},
    'notifications': {'ar': 'تنبيهات الأذان', 'en': 'Prayer notifications'},
    'about': {'ar': 'عن التطبيق', 'en': 'About'},
    'location': {'ar': 'الموقع', 'en': 'Location'},
    'currentLocationLabel': {'ar': 'موقعي الحالي (GPS)', 'en': 'My current location (GPS)'},
    'change': {'ar': 'تغيير', 'en': 'Change'},
    'chooseCityTitle': {'ar': 'اختيار مدينة أخرى', 'en': 'Choose another city'},
    'searchCityHint': {
      'ar': 'اكتب اسم مدينة أو دولة...',
      'en': 'Type a city or country name...',
    },
    'useCurrentLocation': {
      'ar': 'استخدام موقعي الحالي (GPS)',
      'en': 'Use my current location (GPS)',
    },
    'searching': {'ar': 'جاري البحث...', 'en': 'Searching...'},
    'noResults': {'ar': 'مفيش نتائج، جرّب اسم مختلف', 'en': 'No results, try a different name'},
    'searchError': {
      'ar': 'فشل البحث، تأكد من اتصال الإنترنت',
      'en': 'Search failed, check your internet connection',
    },
    'manualLocationNote': {
      'ar': 'البحث محتاج إنترنت مرة واحدة بس، بعدها المواقيت بتتحسب في الجهاز بدون نت',
      'en': 'Searching needs internet once — after that, times are computed fully offline',
    },
  };

  static String of(BuildContext context, String key) {
    final lang = Localizations.localeOf(context).languageCode;
    return forLanguage(lang, key);
  }

  /// Looks up a string without a [BuildContext], for use in places like
  /// scheduled notification callbacks that run outside the widget tree.
  static String forLanguage(String lang, String key) {
    final entry = _values[key];
    if (entry == null) return key;
    return entry[lang] ?? entry['en'] ?? key;
  }
}

import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:home_widget/home_widget.dart';

import '../l10n/app_strings.dart';
import 'date_service.dart';
import 'prayer_times_service.dart';

const _androidWidgetName = 'NextPrayerWidgetProvider';

int _hour12(int hour24) {
  final h = hour24 % 12;
  return h == 0 ? 12 : h;
}

String _formatTime(DateTime time, String language, bool use24HourFormat) {
  final minuteStr = time.minute.toString().padLeft(2, '0');
  if (use24HourFormat) {
    return '${time.hour.toString().padLeft(2, '0')}:$minuteStr';
  }
  final period = AppStrings.forLanguage(language, time.hour < 12 ? 'am' : 'pm');
  return '${_hour12(time.hour)}:$minuteStr $period';
}

/// Pushes the upcoming prayer schedule to the Android home screen widget.
///
/// The native [NextPrayerWidgetProvider] doesn't know how to compute prayer
/// times itself — it just picks the first entry in this list that hasn't
/// passed yet, using Android's own periodic widget refresh. That's what
/// keeps the widget showing the correct next prayer even across a stretch of
/// days where the app is never opened, instead of freezing on whatever was
/// "next" the last time Flutter ran.
Future<void> updateNextPrayerWidget({
  required List<DailyPrayerTimes> upcomingDays,
  required String language,
  required bool use24HourFormat,
  required double qiblaBearing,
}) async {
  // home_widget targets Android/iOS home screens -- no web implementation,
  // and this app is Android-only in production; skip on web.
  if (kIsWeb) return;
  final schedule = [
    for (final day in upcomingDays)
      for (final entry in day.ordered)
        if (notifiablePrayers.contains(entry.key))
          {
            'label': AppStrings.forLanguage(language, entry.key),
            'millis': entry.value.millisecondsSinceEpoch,
            'display': _formatTime(entry.value, language, use24HourFormat),
          },
  ];

  await HomeWidget.saveWidgetData<String>('language', language);
  // Rectangular widget's text-panel header, per DESIGN_RULES.md: the
  // "Prayers" tab label, not "Next prayer" wording -- see
  // Prayer & Qibla App.dc.html:346.
  await HomeWidget.saveWidgetData<String>(
    'next_prayer_header',
    AppStrings.forLanguage(language, 'tabPrayerTimes'),
  );
  await HomeWidget.saveWidgetData<String>(
    'prayer_schedule_json',
    jsonEncode(schedule),
  );
  await HomeWidget.saveWidgetData<String>(
    'hijri_date',
    formatHijri(DateTime.now(), language),
  );
  await HomeWidget.saveWidgetData<String>(
    'qibla_bearing_degrees',
    qiblaBearing.toString(),
  );
  // The native provider computes the countdown text itself (it has to --
  // the schedule is only pushed when times are recomputed, not every
  // minute), so it needs the same localized templates the in-app countdown
  // uses rather than duplicating ar/en wording in Kotlin.
  await HomeWidget.saveWidgetData<String>(
    'remaining_hours_minutes_template',
    AppStrings.forLanguage(language, 'remainingHoursMinutes'),
  );
  await HomeWidget.saveWidgetData<String>(
    'remaining_minutes_template',
    AppStrings.forLanguage(language, 'remainingMinutes'),
  );
  await HomeWidget.updateWidget(androidName: _androidWidgetName);
}

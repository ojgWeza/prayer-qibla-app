// Unit tests for the pure calculation/translation logic. Widget tests are
// intentionally avoided here since the app initializes location, notification
// and ads plugins on startup that aren't available in the test environment.

import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_qibla/l10n/app_strings.dart';
import 'package:prayer_qibla/services/prayer_times_service.dart';

void main() {
  group('AppStrings', () {
    test('returns Arabic and English strings for a known key', () {
      expect(AppStrings.forLanguage('ar', 'fajr'), 'الفجر');
      expect(AppStrings.forLanguage('en', 'fajr'), 'Fajr');
    });

    test('falls back to the key itself when missing', () {
      expect(AppStrings.forLanguage('en', 'not_a_real_key'), 'not_a_real_key');
    });
  });

  group('computeQiblaBearing', () {
    test('matches the reference example from the adhan library', () {
      final bearing =
          computeQiblaBearing(latitude: -39.231, longitude: 12.412);
      expect(bearing, closeTo(28.016, 0.01));
    });
  });

  group('computePrayerTimes', () {
    test('returns the 6 daily times in chronological order for Cairo', () {
      final times = computePrayerTimes(
        latitude: 30.0444,
        longitude: 31.2357,
        date: DateTime(2026, 6, 1),
        methodKey: 'egyptian',
        madhabKey: 'shafi',
      );

      expect(times.fajr.isBefore(times.sunrise), isTrue);
      expect(times.sunrise.isBefore(times.dhuhr), isTrue);
      expect(times.dhuhr.isBefore(times.asr), isTrue);
      expect(times.asr.isBefore(times.maghrib), isTrue);
      expect(times.maghrib.isBefore(times.isha), isTrue);
    });
  });
}

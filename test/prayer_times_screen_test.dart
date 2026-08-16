// Regression test for a real bug found live (2026-08-15): after Isha and
// before midnight, `PrayerTimesScreen` highlighted nothing and showed no
// countdown at all, even though there is a next prayer (tomorrow's Fajr) --
// `_nextPrayerKey` only ever looked inside the single day's `times.ordered`
// list, which has no entry left once Isha has passed. Reported originally as
// "Fajr hadn't been called yet, but Dhuhr was highlighted as next"; this test
// covers the concretely-reproducible instance of the same underlying gap
// (today's list exhausted, no rollover to tomorrow).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_qibla/l10n/app_strings.dart';
import 'package:prayer_qibla/screens/prayer_times_screen.dart';
import 'package:prayer_qibla/services/location_service.dart';
import 'package:prayer_qibla/services/prayer_times_service.dart';

void main() {
  testWidgets(
    'rolls over to tomorrow\'s Fajr for the highlight/countdown once all of '
    'today\'s prayers have passed',
    (tester) async {
      final now = DateTime.now();
      // Every one of today's 6 times is already in the past (a full day
      // behind `now`), matching the after-Isha state.
      final todayTimes = DailyPrayerTimes(
        fajr: now.subtract(const Duration(hours: 20)),
        sunrise: now.subtract(const Duration(hours: 18, minutes: 30)),
        dhuhr: now.subtract(const Duration(hours: 11)),
        asr: now.subtract(const Duration(hours: 7)),
        maghrib: now.subtract(const Duration(hours: 3)),
        isha: now.subtract(const Duration(hours: 1)),
      );
      final tomorrowFajr = now.add(const Duration(hours: 5, minutes: 23));

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: PrayerTimesScreen(
            locationState: LocationState.granted,
            times: todayTimes,
            nextDayFajr: tomorrowFajr,
            language: 'en',
            use24HourFormat: true,
            onRetryLocation: () async {},
          ),
        ),
      );
      await tester.pump();

      // A countdown to tomorrow's Fajr is shown -- not silently dropped
      // until midnight.
      expect(find.textContaining('remaining'), findsOneWidget);

      // The Fajr row displays tomorrow's actual clock time, not today's
      // already-passed one -- the two are deliberately far enough apart
      // (minutes differ) that this distinguishes a stale display from a
      // correct rollover.
      final expectedHour =
          tomorrowFajr.hour.toString().padLeft(2, '0');
      final expectedMinute =
          tomorrowFajr.minute.toString().padLeft(2, '0');
      expect(find.text('$expectedHour:$expectedMinute'), findsOneWidget);

      final staleHour = todayTimes.fajr.hour.toString().padLeft(2, '0');
      final staleMinute = todayTimes.fajr.minute.toString().padLeft(2, '0');
      if ('$staleHour:$staleMinute' != '$expectedHour:$expectedMinute') {
        expect(find.text('$staleHour:$staleMinute'), findsNothing);
      }
    },
  );

  testWidgets(
    'still highlights a normal same-day next prayer when one remains',
    (tester) async {
      final now = DateTime.now();
      final todayTimes = DailyPrayerTimes(
        fajr: now.subtract(const Duration(hours: 6)),
        sunrise: now.subtract(const Duration(hours: 5)),
        dhuhr: now.subtract(const Duration(hours: 1)),
        asr: now.add(const Duration(hours: 3)),
        maghrib: now.add(const Duration(hours: 7)),
        isha: now.add(const Duration(hours: 8)),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: PrayerTimesScreen(
            locationState: LocationState.granted,
            times: todayTimes,
            nextDayFajr: now.add(const Duration(hours: 24)),
            language: 'en',
            use24HourFormat: true,
            onRetryLocation: () async {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text(AppStrings.forLanguage('en', 'asr')), findsOneWidget);
      expect(find.textContaining('remaining'), findsOneWidget);
      final hour = todayTimes.asr.hour.toString().padLeft(2, '0');
      final minute = todayTimes.asr.minute.toString().padLeft(2, '0');
      expect(find.text('$hour:$minute'), findsOneWidget);
    },
  );
}

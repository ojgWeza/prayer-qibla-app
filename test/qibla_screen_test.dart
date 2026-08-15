// Regression test for a real bug found live (2026-08-07): on a platform/
// device where the compass sensor stream never emits a single event (found
// via a web verification build with no flutter_compass implementation, but
// the same thing can happen on a real Android device with no magnetometer),
// QiblaScreen used to spin on CircularProgressIndicator forever with no way
// out. `QiblaScreen.debugCompassStreamOverride` exists solely so this test
// can exercise that path deterministically instead of relying on a real
// sensor or a flaky live click.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_qibla/l10n/app_strings.dart';
import 'package:prayer_qibla/screens/qibla_screen.dart';
import 'package:prayer_qibla/services/location_service.dart';

void main() {
  testWidgets(
    'shows compassUnavailable instead of spinning forever when the '
    'compass stream never emits',
    (tester) async {
      // A stream that never emits and never closes -- the exact shape of
      // the real bug (FlutterCompass.events backed by no platform
      // implementation just sits open forever, unlike a stream that closes
      // without data, which `.timeout()` would not flag as an error).
      final neverEmits = StreamController<CompassEvent>.broadcast();
      addTearDown(neverEmits.close);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: QiblaScreen(
            locationState: LocationState.granted,
            qiblaBearing: 136.0,
            language: 'en',
            onRetryLocation: () async {},
            debugCompassStreamOverride: neverEmits.stream,
          ),
        ),
      );

      // Immediately after first pump: still within the timeout window,
      // should show the loading spinner, not the unavailable message yet.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(AppStrings.forLanguage('en', 'compassUnavailable')),
          findsNothing);

      // Advance past the 4-second timeout configured in QiblaScreen.
      await tester.pump(const Duration(seconds: 5));

      expect(find.text(AppStrings.forLanguage('en', 'compassUnavailable')),
          findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    },
  );
}

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';

import '../l10n/app_strings.dart';
import '../services/location_service.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/qibla_compass.dart';

class QiblaScreen extends StatefulWidget {
  final LocationState locationState;
  final double? qiblaBearing;
  final String language;
  final Future<void> Function() onRetryLocation;

  /// Overrides the real `FlutterCompass.events` stream -- exists purely so
  /// widget tests can exercise the "compass never emits" timeout path
  /// deterministically, without a real sensor or platform channel.
  final Stream<CompassEvent>? debugCompassStreamOverride;

  const QiblaScreen({
    super.key,
    required this.locationState,
    required this.qiblaBearing,
    required this.language,
    required this.onRetryLocation,
    this.debugCompassStreamOverride,
  });

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  // Some platforms (no compass sensor, or -- as found live on a web verify
  // build -- flutter_compass has no web implementation at all) never emit a
  // single event on FlutterCompass.events, which used to leave this screen
  // spinning on the loading indicator forever with no way out. Timing out
  // the stream if nothing arrives within a few seconds turns that into the
  // existing "compassUnavailable" message instead.
  late final Stream<CompassEvent>? _compassStream =
      (widget.debugCompassStreamOverride ?? FlutterCompass.events)
          ?.timeout(const Duration(seconds: 4));

  // How close (in degrees) heading must be to the qibla bearing to count as
  // "facing Qibla" -- mirrors the competitor app's Kaaba-icon-turns-blue
  // threshold rather than requiring an exact 0 diff, which the magnetometer
  // never holds still enough to hit.
  static const double _alignmentThresholdDegrees = 5;

  bool _wasAligned = false;

  @override
  Widget build(BuildContext context) {
    if (widget.locationState == LocationState.denied ||
        widget.locationState == LocationState.deniedForever ||
        widget.locationState == LocationState.serviceDisabled) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off_rounded, size: 48),
              const SizedBox(height: 16),
              Text(
                AppStrings.of(context, 'locationDenied'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: widget.onRetryLocation,
                child: Text(AppStrings.of(context, 'grantPermission')),
              ),
            ],
          ),
        ),
      );
    }

    final qiblaBearing = widget.qiblaBearing;
    if (qiblaBearing == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final compassStream = _compassStream;
    if (compassStream == null) {
      return Center(child: Text(AppStrings.of(context, 'compassUnavailable')));
    }

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<CompassEvent>(
            stream: compassStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                // Either no compass sensor, or (found live on a web verify
                // build) a platform with no flutter_compass implementation
                // at all -- either way the stream never emits, and the
                // `.timeout()` above turns that into an error instead of an
                // indefinite spinner.
                return Center(
                  child: Text(AppStrings.of(context, 'compassUnavailable')),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final heading = snapshot.data!.heading;
              if (heading == null) {
                return Center(
                  child: Text(AppStrings.of(context, 'compassUnavailable')),
                );
              }
              // QiblaCompass's needle is built pointing straight up (toward
              // the tip) at angle == 0, and canvas.rotate() turns clockwise
              // for positive radians. flutter_compass's `heading` is degrees
              // clockwise from north, same convention as the qibla bearing,
              // so the screen angle of an absolute direction D while the
              // phone faces `heading` is D - heading (turn the phone
              // clockwise and every absolute-direction marker swings
              // counterclockwise on screen, like a real compass card).
              // Confirmed 2026-08-10 against a competitor app's rotating-ring
              // qibla compass photographed on the same Mi 10: its
              // fixed-bearing marker visibly moved counterclockwise on
              // screen as the ring (driven by device heading) rotated
              // clockwise, matching bearing - heading, not heading - bearing.
              // A prior session's live 90 deg-turn test was misread as
              // confirming heading - qiblaBearing; that formula actually
              // predicts the needle rotating the *same* direction as the
              // phone, which contradicts the observed counterclockwise
              // rotation for a clockwise turn -- so this flips the sign back.
              final angle = (qiblaBearing - heading) * pi / 180;

              // Normalize the raw bearing-minus-heading diff into -180..180
              // before comparing to the threshold, so e.g. heading=359,
              // bearing=1 (a 2 deg diff) doesn't read as a 358 deg miss.
              final rawDiff = (qiblaBearing - heading) % 360;
              final diff = rawDiff > 180 ? rawDiff - 360 : rawDiff;
              final isAligned = diff.abs() <= _alignmentThresholdDegrees;
              if (isAligned && !_wasAligned) {
                HapticFeedback.mediumImpact();
              }
              _wasAligned = isAligned;

              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.of(context, 'qiblaTitle'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 24),
                    QiblaCompass(
                      angle: angle,
                      language: widget.language,
                      isAligned: isAligned,
                    ),
                    const SizedBox(height: 24),
                    Text('${qiblaBearing.toStringAsFixed(0)}°'),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        AppStrings.of(context, 'qiblaHint'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SafeArea(top: false, child: BannerAdWidget()),
      ],
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../services/date_service.dart';
import '../services/location_service.dart';
import '../services/prayer_times_service.dart';
import '../theme/app_theme.dart';
import '../widgets/banner_ad_widget.dart';

class PrayerTimesScreen extends StatefulWidget {
  final LocationState locationState;
  final DailyPrayerTimes? times;
  final String language;
  final bool use24HourFormat;
  final Future<void> Function() onRetryLocation;

  const PrayerTimesScreen({
    super.key,
    required this.locationState,
    required this.times,
    required this.language,
    required this.use24HourFormat,
    required this.onRetryLocation,
  });

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String? _nextPrayerKey(DailyPrayerTimes times) {
    final now = DateTime.now();
    for (final entry in times.ordered) {
      if (entry.key == 'sunrise') continue;
      if (entry.value.isAfter(now)) return entry.key;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final times = widget.times;

    if (widget.locationState == LocationState.denied ||
        widget.locationState == LocationState.deniedForever ||
        widget.locationState == LocationState.serviceDisabled) {
      return _PermissionMessage(onRetry: widget.onRetryLocation);
    }

    if (times == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(AppStrings.of(context, 'locating')),
          ],
        ),
      );
    }

    final nextKey = _nextPrayerKey(times);
    final today = DateTime.now();
    final remainingText = nextKey == null
        ? null
        : _formatRemaining(
            context,
            times.ordered
                .firstWhere((entry) => entry.key == nextKey)
                .value
                .difference(today),
          );

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: widget.onRetryLocation,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _DateHeader(
                  gregorian: formatGregorian(today, widget.language),
                  hijri: formatHijri(today, widget.language),
                ),
                const SizedBox(height: 4),
                for (final entry in times.ordered)
                  _PrayerRow(
                    label: AppStrings.of(context, entry.key),
                    time: entry.value,
                    highlighted: entry.key == nextKey,
                    use24HourFormat: widget.use24HourFormat,
                    remainingText:
                        entry.key == nextKey ? remainingText : null,
                  ),
              ],
            ),
          ),
        ),
        const SafeArea(top: false, child: BannerAdWidget()),
      ],
    );
  }
}

class _DateHeader extends StatelessWidget {
  final String gregorian;
  final String hijri;

  const _DateHeader({required this.gregorian, required this.hijri});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(gregorian, style: theme.textTheme.titleSmall),
          Text(
            hijri,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }
}

/// Formats a countdown to the next prayer, e.g. "4 hours & 46 minutes
/// remaining" or "12 minutes remaining" once under an hour. Clamps negative
/// durations (the boundary moment right as a prayer time passes) to zero.
String _formatRemaining(BuildContext context, Duration remaining) {
  final clamped = remaining.isNegative ? Duration.zero : remaining;
  final hours = clamped.inHours;
  final minutes = clamped.inMinutes % 60;
  if (hours > 0) {
    return AppStrings.of(context, 'remainingHoursMinutes')
        .replaceFirst('{h}', '$hours')
        .replaceFirst('{m}', '$minutes');
  }
  return AppStrings.of(context, 'remainingMinutes')
      .replaceFirst('{m}', '$minutes');
}

int _hour12(int hour24) {
  final h = hour24 % 12;
  return h == 0 ? 12 : h;
}

class _PrayerRow extends StatelessWidget {
  final String label;
  final DateTime time;
  final bool highlighted;
  final bool use24HourFormat;
  final String? remainingText;

  const _PrayerRow({
    required this.label,
    required this.time,
    required this.highlighted,
    required this.use24HourFormat,
    this.remainingText,
  });

  @override
  Widget build(BuildContext context) {
    final minuteStr = time.minute.toString().padLeft(2, '0');
    final timeStr = use24HourFormat
        ? '${time.hour.toString().padLeft(2, '0')}:$minuteStr'
        : '${_hour12(time.hour)}:$minuteStr '
            '${AppStrings.of(context, time.hour < 12 ? 'am' : 'pm')}';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // accent100/accent700 are the light-ramp tokens -- always using them for
    // the highlighted card left the title (theme-aware `text` color, which
    // turns near-white in dark mode) sitting on a near-white background:
    // light-on-light with no contrast. Dark mode needs the dark-ramp
    // equivalents instead, same pairing logic as the qibla needle's
    // isDark branch in qibla_compass.dart.
    final highlightBg = isDark ? AppTheme.accent900 : AppTheme.accent100;
    final highlightBorder = isDark ? AppTheme.accent700 : AppTheme.accent300;
    final highlightText = isDark ? AppTheme.accent100 : AppTheme.accent700;
    // Matches CardTheme's own rest-state tokens (app_theme.dart) so the
    // animated version below looks identical to a plain Card when unhighlighted.
    final restBg = theme.colorScheme.surface;
    final restBorder = theme.colorScheme.outline;
    const highlightDuration = Duration(milliseconds: 200);
    const highlightCurve = Curves.easeOut;
    final titleStyle = highlighted
        ? theme.textTheme.titleMedium?.copyWith(
            color: isDark ? AppTheme.accent100 : null,
          )
        : theme.textTheme.titleMedium;
    final trailingStyle = highlighted
        ? theme.textTheme.titleLarge?.copyWith(
            color: isDark ? AppTheme.accent100 : null,
          )
        : theme.textTheme.titleLarge;
    // Which row is "next" can change instantly (a settings edit reshuffles
    // it, or a prayer time passes while the app is open) -- an AnimatedContainer
    // (Card's color/shape aren't implicitly animatable) plus AnimatedDefaultTextStyle
    // keep the background/border and text colors crossfading together instead
    // of one snapping ahead of the other.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: AnimatedContainer(
        duration: highlightDuration,
        curve: highlightCurve,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: highlighted ? highlightBg : restBg,
          borderRadius: const BorderRadius.all(Radius.circular(AppTheme.radiusLg)),
          border: Border.all(color: highlighted ? highlightBorder : restBorder),
        ),
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            title: AnimatedDefaultTextStyle(
              duration: highlightDuration,
              curve: highlightCurve,
              style: titleStyle ?? const TextStyle(),
              child: Text(label),
            ),
            trailing: AnimatedDefaultTextStyle(
              duration: highlightDuration,
              curve: highlightCurve,
              style: trailingStyle ?? const TextStyle(),
              child: Text(timeStr),
            ),
            subtitle: highlighted
                ? Text(
                    remainingText == null
                        ? AppStrings.of(context, 'nextPrayer')
                        : '${AppStrings.of(context, 'nextPrayer')} — $remainingText',
                    style: theme.textTheme.bodySmall?.copyWith(color: highlightText),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class _PermissionMessage extends StatelessWidget {
  final VoidCallback onRetry;
  const _PermissionMessage({required this.onRetry});

  @override
  Widget build(BuildContext context) {
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
              onPressed: onRetry,
              child: Text(AppStrings.of(context, 'grantPermission')),
            ),
          ],
        ),
      ),
    );
  }
}

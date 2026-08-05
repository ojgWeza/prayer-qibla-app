import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../services/date_service.dart';
import '../services/location_service.dart';
import '../services/prayer_times_service.dart';
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

int _hour12(int hour24) {
  final h = hour24 % 12;
  return h == 0 ? 12 : h;
}

class _PrayerRow extends StatelessWidget {
  final String label;
  final DateTime time;
  final bool highlighted;
  final bool use24HourFormat;

  const _PrayerRow({
    required this.label,
    required this.time,
    required this.highlighted,
    required this.use24HourFormat,
  });

  @override
  Widget build(BuildContext context) {
    final minuteStr = time.minute.toString().padLeft(2, '0');
    final timeStr = use24HourFormat
        ? '${time.hour.toString().padLeft(2, '0')}:$minuteStr'
        : '${_hour12(time.hour)}:$minuteStr '
            '${AppStrings.of(context, time.hour < 12 ? 'am' : 'pm')}';
    final theme = Theme.of(context);
    return Card(
      color: highlighted ? theme.colorScheme.primaryContainer : null,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(label, style: theme.textTheme.titleMedium),
        trailing: Text(timeStr, style: theme.textTheme.titleLarge),
        subtitle: highlighted
            ? Text(AppStrings.of(context, 'nextPrayer'))
            : null,
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
            const Icon(Icons.location_off, size: 48),
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

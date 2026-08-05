import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../services/location_service.dart';
import '../services/prayer_times_service.dart';
import '../widgets/banner_ad_widget.dart';

class PrayerTimesScreen extends StatefulWidget {
  final LocationState locationState;
  final DailyPrayerTimes? times;
  final VoidCallback onRetryLocation;

  const PrayerTimesScreen({
    super.key,
    required this.locationState,
    required this.times,
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

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final entry in times.ordered)
                _PrayerRow(
                  label: AppStrings.of(context, entry.key),
                  time: entry.value,
                  highlighted: entry.key == nextKey,
                ),
            ],
          ),
        ),
        const SafeArea(top: false, child: BannerAdWidget()),
      ],
    );
  }
}

class _PrayerRow extends StatelessWidget {
  final String label;
  final DateTime time;
  final bool highlighted;

  const _PrayerRow({
    required this.label,
    required this.time,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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

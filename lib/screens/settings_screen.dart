import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../services/prayer_times_service.dart';

class SettingsScreen extends StatelessWidget {
  final String language;
  final String calculationMethod;
  final String madhab;
  final Map<int, Map<String, bool>> notificationMatrix;
  final String locationLabel;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<String> onCalculationMethodChanged;
  final ValueChanged<String> onMadhabChanged;
  final void Function(int weekday, String prayer, bool enabled)
      onNotificationToggled;
  final VoidCallback onChangeLocation;

  const SettingsScreen({
    super.key,
    required this.language,
    required this.calculationMethod,
    required this.madhab,
    required this.notificationMatrix,
    required this.locationLabel,
    required this.onLanguageChanged,
    required this.onCalculationMethodChanged,
    required this.onMadhabChanged,
    required this.onNotificationToggled,
    required this.onChangeLocation,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          title: Text(AppStrings.of(context, 'location')),
          subtitle: Text(locationLabel),
          trailing: TextButton(
            onPressed: onChangeLocation,
            child: Text(AppStrings.of(context, 'change')),
          ),
        ),
        const Divider(),
        ListTile(
          title: Text(AppStrings.of(context, 'language')),
          trailing: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'ar', label: Text('العربية')),
              ButtonSegment(value: 'en', label: Text('English')),
            ],
            selected: {language},
            onSelectionChanged: (s) => onLanguageChanged(s.first),
          ),
        ),
        const Divider(),
        ListTile(
          title: Text(AppStrings.of(context, 'calculationMethod')),
          trailing: DropdownButton<String>(
            value: calculationMethod,
            onChanged: (v) {
              if (v != null) onCalculationMethodChanged(v);
            },
            items: [
              for (final method in availableCalculationMethods)
                DropdownMenuItem(value: method, child: Text(method)),
            ],
          ),
        ),
        const Divider(),
        ListTile(
          title: Text(AppStrings.of(context, 'madhab')),
          trailing: DropdownButton<String>(
            value: madhab,
            onChanged: (v) {
              if (v != null) onMadhabChanged(v);
            },
            items: [
              DropdownMenuItem(
                value: 'shafi',
                child: Text(AppStrings.of(context, 'shafi')),
              ),
              DropdownMenuItem(
                value: 'hanafi',
                child: Text(AppStrings.of(context, 'hanafi')),
              ),
            ],
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
          child: Text(
            AppStrings.of(context, 'notifications'),
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppStrings.of(context, 'notificationsHint'),
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.outline),
          ),
        ),
        for (final prayer in notifiablePrayers)
          _PrayerDayToggleRow(
            prayer: prayer,
            enabledByWeekday: {
              for (var weekday = 1; weekday <= 7; weekday++)
                weekday: notificationMatrix[weekday]?[prayer] ?? true,
            },
            onDayToggled: (weekday, enabled) =>
                onNotificationToggled(weekday, prayer, enabled),
          ),
        const Divider(),
        ListTile(
          title: Text(AppStrings.of(context, 'about')),
          subtitle: const Text('v1.0.0'),
        ),
      ],
    );
  }
}

/// One prayer's row of 7 day chips — tap a day to mute/unmute that
/// prayer's alert on just that weekday (e.g. Friday Dhuhr for Jumu'ah).
class _PrayerDayToggleRow extends StatelessWidget {
  final String prayer;
  final Map<int, bool> enabledByWeekday;
  final void Function(int weekday, bool enabled) onDayToggled;

  const _PrayerDayToggleRow({
    required this.prayer,
    required this.enabledByWeekday,
    required this.onDayToggled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.of(context, prayer),
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var weekday = 1; weekday <= 7; weekday++)
                _DayChip(
                  label: AppStrings.of(context, 'day$weekday'),
                  selected: enabledByWeekday[weekday] ?? true,
                  onTap: () => onDayToggled(
                    weekday,
                    !(enabledByWeekday[weekday] ?? true),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DayChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? scheme.primaryContainer : Colors.transparent,
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: selected ? scheme.onPrimaryContainer : scheme.outline,
              ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../services/prayer_times_service.dart';

class SettingsScreen extends StatelessWidget {
  final String language;
  final bool use24HourFormat;
  final String calculationMethod;
  final String madhab;
  final String locationLabel;
  final String appearanceMode;
  final int weekStart;
  final bool notificationsEnabled;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<bool> onTimeFormatChanged;
  final ValueChanged<String> onCalculationMethodChanged;
  final ValueChanged<String> onMadhabChanged;
  final VoidCallback onChangeLocation;
  final ValueChanged<String> onAppearanceModeChanged;
  final ValueChanged<int> onWeekStartChanged;
  final ValueChanged<bool> onNotificationsEnabledChanged;
  final VoidCallback onCustomizeByDay;

  const SettingsScreen({
    super.key,
    required this.language,
    required this.use24HourFormat,
    required this.calculationMethod,
    required this.madhab,
    required this.locationLabel,
    required this.appearanceMode,
    required this.weekStart,
    required this.notificationsEnabled,
    required this.onLanguageChanged,
    required this.onTimeFormatChanged,
    required this.onCalculationMethodChanged,
    required this.onMadhabChanged,
    required this.onChangeLocation,
    required this.onAppearanceModeChanged,
    required this.onWeekStartChanged,
    required this.onNotificationsEnabledChanged,
    required this.onCustomizeByDay,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Time & calculation
        ListTile(
          title: Text(AppStrings.of(context, 'timeFormat')),
          trailing: SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: true,
                label: Text(AppStrings.of(context, 'timeFormat24')),
              ),
              ButtonSegment(
                value: false,
                label: Text(AppStrings.of(context, 'timeFormat12')),
              ),
            ],
            selected: {use24HourFormat},
            onSelectionChanged: (s) => onTimeFormatChanged(s.first),
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
        ListTile(
          title: Text(AppStrings.of(context, 'weekStart')),
          trailing: DropdownButton<int>(
            value: weekStart,
            onChanged: (v) {
              if (v != null) onWeekStartChanged(v);
            },
            items: [
              for (var offset = 0; offset < 7; offset++)
                DropdownMenuItem(
                  value: offset,
                  child: Text(
                    AppStrings.of(context, 'fullDay${offset + 1}'),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 32),

        // Notifications
        SwitchListTile(
          title: Text(AppStrings.of(context, 'notificationsEnable')),
          value: notificationsEnabled,
          onChanged: onNotificationsEnabledChanged,
        ),
        ListTile(
          title: Text(AppStrings.of(context, 'customizeByDay')),
          trailing: const Icon(Icons.chevron_right),
          onTap: onCustomizeByDay,
        ),
        const Divider(height: 32),

        // Language & appearance
        ListTile(
          title: Text(AppStrings.of(context, 'language')),
          trailing: SegmentedButton<String>(
            showSelectedIcon: false,
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
          title: Text(AppStrings.of(context, 'location')),
          subtitle: Text(locationLabel),
          trailing: TextButton(
            onPressed: onChangeLocation,
            child: Text(AppStrings.of(context, 'change')),
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            AppStrings.of(context, 'appearance'),
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        RadioGroup<String>(
          groupValue: appearanceMode,
          onChanged: (v) {
            if (v != null) onAppearanceModeChanged(v);
          },
          child: Column(
            children: [
              for (final mode in const [
                'afterMaghrib',
                'light',
                'dark',
                'system',
              ])
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    AppStrings.of(
                      context,
                      switch (mode) {
                        'light' => 'appearanceLight',
                        'dark' => 'appearanceDark',
                        'system' => 'appearanceSystem',
                        _ => 'appearanceAfterMaghrib',
                      },
                    ),
                  ),
                  value: mode,
                ),
            ],
          ),
        ),
        const Divider(height: 32),

        // About
        ListTile(
          title: Text(AppStrings.of(context, 'about')),
          subtitle: const Text('v1.0.0'),
        ),
      ],
    );
  }
}

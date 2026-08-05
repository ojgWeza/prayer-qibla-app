import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../services/prayer_times_service.dart';

class SettingsScreen extends StatelessWidget {
  final String language;
  final String calculationMethod;
  final String madhab;
  final bool notificationsEnabled;
  final String locationLabel;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<String> onCalculationMethodChanged;
  final ValueChanged<String> onMadhabChanged;
  final ValueChanged<bool> onNotificationsChanged;
  final VoidCallback onChangeLocation;

  const SettingsScreen({
    super.key,
    required this.language,
    required this.calculationMethod,
    required this.madhab,
    required this.notificationsEnabled,
    required this.locationLabel,
    required this.onLanguageChanged,
    required this.onCalculationMethodChanged,
    required this.onMadhabChanged,
    required this.onNotificationsChanged,
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
        SwitchListTile(
          title: Text(AppStrings.of(context, 'notifications')),
          value: notificationsEnabled,
          onChanged: onNotificationsChanged,
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

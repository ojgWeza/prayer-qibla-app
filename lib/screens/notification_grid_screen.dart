import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../services/prayer_times_service.dart';
import '../services/prefs_service.dart';

/// Full-screen "customize by day" grid: prayers as columns, days as rows in
/// week-start order, each cell a checkbox chip. Independent of the master
/// "enable prayer notifications" toggle in Settings.
class NotificationGridScreen extends StatefulWidget {
  final String language;
  final int weekStart;

  const NotificationGridScreen({
    super.key,
    required this.language,
    required this.weekStart,
  });

  @override
  State<NotificationGridScreen> createState() =>
      _NotificationGridScreenState();
}

class _NotificationGridScreenState extends State<NotificationGridScreen> {
  final _prefs = PrefsService();

  // Grid keyed by [weekday][prayerKey], weekday = DateTime.weekday (1..7).
  Map<int, Map<String, bool>>? _grid;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final grid = <int, Map<String, bool>>{};
    for (var weekday = 1; weekday <= 7; weekday++) {
      grid[weekday] = {
        for (final prayer in notifiablePrayers)
          prayer: await _prefs.getNotifDayEnabled(weekday, prayer),
      };
    }
    if (mounted) setState(() => _grid = grid);
  }

  Future<void> _toggle(int weekday, String prayer) async {
    final grid = _grid;
    if (grid == null) return;
    final newValue = !(grid[weekday]![prayer]!);
    setState(() => grid[weekday]![prayer] = newValue);
    await _prefs.setNotifDayEnabled(weekday, prayer, newValue);
  }

  @override
  Widget build(BuildContext context) {
    final grid = _grid;
    // Week-start ordered weekday list (0=Monday..6=Sunday offset).
    final orderedWeekdays = [
      for (var i = 0; i < 7; i++) ((widget.weekStart + i) % 7) + 1,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.forLanguage(widget.language, 'notificationGridTitle')),
      ),
      body: grid == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: const {0: FixedColumnWidth(96)},
                children: [
                  TableRow(
                    children: [
                      const SizedBox(),
                      for (final prayer in notifiablePrayers)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            AppStrings.forLanguage(widget.language, prayer),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ),
                    ],
                  ),
                  for (final weekday in orderedWeekdays)
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            AppStrings.forLanguage(
                              widget.language,
                              'fullDay$weekday',
                            ),
                          ),
                        ),
                        for (final prayer in notifiablePrayers)
                          Center(
                            child: _GridCell(
                              enabled: grid[weekday]![prayer]!,
                              semanticLabel:
                                  '${AppStrings.forLanguage(widget.language, 'fullDay$weekday')} '
                                  '${AppStrings.forLanguage(widget.language, prayer)}',
                              onTap: () => _toggle(weekday, prayer),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}

class _GridCell extends StatelessWidget {
  final bool enabled;
  final String semanticLabel;
  final VoidCallback onTap;

  const _GridCell({
    required this.enabled,
    required this.semanticLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Semantics(
        label: semanticLabel,
        toggled: enabled,
        button: true,
        child: Container(
          width: 36,
          height: 36,
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color:
                enabled ? colorScheme.primary.withValues(alpha: 0.15) : null,
            border: Border.all(
              color: enabled ? colorScheme.primary : colorScheme.outline,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: enabled
              ? Icon(Icons.check, size: 18, color: colorScheme.primary)
              : null,
        ),
      ),
    );
  }
}

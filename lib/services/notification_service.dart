import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'prayer_times_service.dart';

/// Schedules a local notification for each of the 5 daily prayers.
/// Everything runs on-device — no push server, no backend involved.
class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    // flutter_local_notifications/flutter_timezone have no web
    // implementation -- this app is Android-only in production; skip on
    // web instead of blocking bootstrap on a missing platform channel.
    if (kIsWeb) return;
    if (_initialized) return;
    tz_data.initializeTimeZones();
    final localTimezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimezone.identifier));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );
    _initialized = true;
  }

  Future<void> requestPermission() async {
    if (kIsWeb) return;
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> cancelAll() {
    if (kIsWeb) return Future.value();
    return _plugin.cancelAll();
  }

  /// Schedules prayer notifications for a rolling window of days (today
  /// plus however many are passed in [upcomingDays]), skipping any prayer
  /// whose weekday+prayer combination [isEnabled] says is muted, and any
  /// time already in the past. Prayer times drift by a few minutes daily,
  /// so each day is scheduled with its own freshly-computed time rather
  /// than relying on a fixed weekly-recurring alarm.
  ///
  /// Called on app start and whenever settings/location change; reopening
  /// the app re-derives this window, which is what keeps it current even
  /// though nothing runs in the background between opens.
  Future<void> scheduleUpcoming(
    List<DailyPrayerTimes> upcomingDays, {
    required bool Function(int weekday, String prayerKey) isEnabled,
    required String Function(String prayerKey) labelFor,
  }) async {
    if (kIsWeb) return;
    await cancelAll();
    final now = tz.TZDateTime.now(tz.local);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'prayer_times_channel',
        'Prayer times',
        channelDescription: 'Reminders for daily prayer times',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    var id = 0;
    for (final times in upcomingDays) {
      final weekday = times.fajr.weekday;
      for (final entry in times.ordered) {
        if (!notifiablePrayers.contains(entry.key)) continue;
        if (!isEnabled(weekday, entry.key)) continue;
        final scheduled = tz.TZDateTime.from(entry.value, tz.local);
        if (scheduled.isBefore(now)) continue;
        await _plugin.zonedSchedule(
          id: id++,
          scheduledDate: scheduled,
          title: labelFor(entry.key),
          body: labelFor(entry.key),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    }
  }
}

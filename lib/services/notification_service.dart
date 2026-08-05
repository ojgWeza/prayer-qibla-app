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
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  /// Schedules today's remaining prayer notifications. Called on app start
  /// and whenever settings/location change; past prayers for today are skipped.
  Future<void> scheduleForToday(
    DailyPrayerTimes times, {
    required String Function(String prayerKey) labelFor,
  }) async {
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
    for (final entry in times.ordered) {
      if (entry.key == 'sunrise') continue;
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

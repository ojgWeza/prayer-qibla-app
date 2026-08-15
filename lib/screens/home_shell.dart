import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../services/geocoding_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/prayer_times_service.dart';
import '../services/prefs_service.dart';
import '../services/widget_service.dart';
import '../theme/app_theme.dart';
import '../widgets/star_watermark.dart';
import 'city_search_screen.dart';
import 'notification_grid_screen.dart';
import 'prayer_times_screen.dart';
import 'qibla_screen.dart';
import 'settings_screen.dart';

// Shown before the user has ever picked a location or resolved a GPS fix,
// so first launch never blocks on a permission prompt with nothing on
// screen. The user can switch away from it any time via the location chip.
const _defaultLatitude = 30.0444;
const _defaultLongitude = 31.2357;

class HomeShell extends StatefulWidget {
  final ValueChanged<Locale> onLocaleChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const HomeShell({
    super.key,
    required this.onLocaleChanged,
    required this.onThemeModeChanged,
  });

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _prefs = PrefsService();
  final _locationService = LocationService();
  final _notificationService = NotificationService();

  int _tabIndex = 0;

  LocationState _locationState = LocationState.unknown;
  double? _latitude;
  double? _longitude;
  DailyPrayerTimes? _prayerTimes;
  double? _qiblaBearing;
  DateTime? _prayerTimesDate;

  /// Name of the manually picked city, or null while using GPS.
  String? _manualLocationName;

  /// True while showing the no-location-ever-chosen Cairo fallback, so its
  /// label can be re-resolved in the current language on every build instead
  /// of being frozen in whatever language was active when it was first set.
  bool _usingDefaultLocation = false;

  String _language = 'ar';
  bool _use24HourFormat = true;
  String _calculationMethod = 'egyptian';
  String _madhab = 'shafi';
  String _appearanceMode = 'afterMaghrib';
  int _weekStart = 5;
  bool _notificationsEnabled = true;

  Timer? _appearanceTicker;

  @override
  void initState() {
    super.initState();
    _bootstrap();
    // The 'afterMaghrib' appearance mode flips purely with wall-clock time
    // (no other state change triggers a rebuild at the moment Maghrib/Fajr
    // passes), so a light periodic tick keeps it accurate. This same tick
    // also catches the midnight day rollover: `_prayerTimes` was previously
    // only ever recomputed on bootstrap/location/settings changes, so an app
    // left open past midnight kept showing yesterday's (all-already-passed)
    // times with no next prayer and a frozen/nonsensical countdown until
    // manually refreshed.
    _appearanceTicker = Timer.periodic(
      const Duration(minutes: 1),
      (_) {
        _applyAppearance();
        _recomputeIfDayChanged();
      },
    );
  }

  @override
  void dispose() {
    _appearanceTicker?.cancel();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    _language = await _prefs.getLanguage();
    _use24HourFormat = await _prefs.getUse24HourFormat();
    _calculationMethod = await _prefs.getCalculationMethod();
    _madhab = await _prefs.getMadhab();
    _appearanceMode = await _prefs.getAppearanceMode();
    _weekStart = await _prefs.getWeekStart();
    _notificationsEnabled = await _prefs.getNotificationsEnabled();
    if (mounted) {
      widget.onLocaleChanged(Locale(_language));
      setState(() {});
    }
    _applyAppearance();

    await _notificationService.init();
    await _notificationService.requestPermission();

    final manual = await _prefs.getManualLocation();
    if (manual != null) {
      _latitude = manual.latitude;
      _longitude = manual.longitude;
      _manualLocationName = manual.name;
      if (mounted) setState(() => _locationState = LocationState.granted);
      _recomputeTimesAndQibla();
      return;
    }

    final cached = await _prefs.getCachedGpsLocation();
    if (cached != null) {
      // Show times instantly from the last known fix instead of blocking
      // startup on a fresh GPS call, then quietly refresh in the background.
      _latitude = cached.latitude;
      _longitude = cached.longitude;
      if (mounted) setState(() => _locationState = LocationState.granted);
      _recomputeTimesAndQibla();
      unawaited(_backgroundLocationRefresh());
      return;
    }

    // Never picked a location before and no cached GPS fix yet -- default to
    // Cairo instead of prompting for GPS automatically. The user opts into
    // GPS or a specific city explicitly via the location picker.
    _latitude = _defaultLatitude;
    _longitude = _defaultLongitude;
    _usingDefaultLocation = true;
    if (mounted) setState(() => _locationState = LocationState.granted);
    _recomputeTimesAndQibla();
  }

  /// Refreshes the GPS fix without disturbing an already-showing cached
  /// location on failure -- used on startup once cached coordinates are
  /// already on screen, so a denied/disabled result shouldn't blank the UI.
  Future<void> _backgroundLocationRefresh() async {
    final result = await _locationService.getCurrentLocation();
    if (!mounted) return;
    final position = result.position;
    if (position == null) return;

    _latitude = position.latitude;
    _longitude = position.longitude;
    _usingDefaultLocation = false;
    await _prefs.setCachedGpsLocation(position.latitude, position.longitude);
    _recomputeTimesAndQibla();
  }

  Future<void> _refreshLocation() async {
    final result = await _locationService.getCurrentLocation();
    if (!mounted) return;
    setState(() => _locationState = result.state);
    final position = result.position;
    if (position == null) return;

    _latitude = position.latitude;
    _longitude = position.longitude;
    _usingDefaultLocation = false;
    await _prefs.setCachedGpsLocation(position.latitude, position.longitude);
    _recomputeTimesAndQibla();
  }

  void _recomputeTimesAndQibla() {
    final lat = _latitude;
    final lng = _longitude;
    if (lat == null || lng == null) return;

    final today = DateTime.now();
    final upcomingDays = [
      for (var offset = 0; offset < 7; offset++)
        computePrayerTimes(
          latitude: lat,
          longitude: lng,
          date: today.add(Duration(days: offset)),
          methodKey: _calculationMethod,
          madhabKey: _madhab,
        ),
    ];
    final bearing = computeQiblaBearing(latitude: lat, longitude: lng);

    setState(() {
      _prayerTimes = upcomingDays.first;
      _qiblaBearing = bearing;
      _prayerTimesDate = DateTime(today.year, today.month, today.day);
    });

    _rescheduleNotifications(upcomingDays);
    _applyAppearance();

    updateNextPrayerWidget(
      upcomingDays: upcomingDays,
      language: _language,
      use24HourFormat: _use24HourFormat,
      qiblaBearing: bearing,
    );
  }

  /// Re-derives today's prayer times once the wall-clock date has actually
  /// moved past the date they were last computed for -- see the ticker
  /// comment in `initState` for why this is needed at all.
  void _recomputeIfDayChanged() {
    final lastDate = _prayerTimesDate;
    if (lastDate == null) return;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (today != lastDate) {
      _recomputeTimesAndQibla();
    }
  }

  Future<void> _rescheduleNotifications(
    List<DailyPrayerTimes> upcomingDays,
  ) async {
    if (!_notificationsEnabled) {
      await _notificationService.cancelAll();
      return;
    }
    final enabledFlags = await Future.wait([
      for (final times in upcomingDays)
        for (final entry in times.ordered)
          if (notifiablePrayers.contains(entry.key))
            _prefs
                .getNotifDayEnabled(times.fajr.weekday, entry.key)
                .then((v) => MapEntry('${times.fajr.weekday}_${entry.key}', v)),
    ]);
    final enabledMap = Map.fromEntries(enabledFlags);

    await _notificationService.scheduleUpcoming(
      upcomingDays,
      isEnabled: (weekday, prayer) =>
          enabledMap['${weekday}_$prayer'] ?? true,
      labelFor: (key) => AppStrings.forLanguage(_language, key),
    );
  }

  /// Computes the effective `ThemeMode` for the current `_appearanceMode`
  /// and pushes it up to `MaterialApp`. For `'afterMaghrib'`, dark runs from
  /// today's Maghrib to tomorrow's Fajr, derived from the already-computed
  /// prayer times rather than a fixed clock time.
  void _applyAppearance() {
    switch (_appearanceMode) {
      case 'light':
        widget.onThemeModeChanged(ThemeMode.light);
        return;
      case 'dark':
        widget.onThemeModeChanged(ThemeMode.dark);
        return;
      case 'system':
        widget.onThemeModeChanged(ThemeMode.system);
        return;
      case 'afterMaghrib':
      default:
        final times = _prayerTimes;
        if (times == null) {
          widget.onThemeModeChanged(ThemeMode.system);
          return;
        }
        final now = DateTime.now();
        final isDark = now.isAfter(times.maghrib) || now.isBefore(times.fajr);
        widget.onThemeModeChanged(isDark ? ThemeMode.dark : ThemeMode.light);
    }
  }

  Future<void> _openLocationPicker() async {
    final result = await Navigator.of(context).push<Object>(
      MaterialPageRoute(builder: (_) => const CitySearchScreen()),
    );

    if (result is CitySearchResult) {
      final manual = ManualLocation(
        name: result.displayName,
        latitude: result.latitude,
        longitude: result.longitude,
      );
      await _prefs.setManualLocation(manual);
      setState(() {
        _latitude = manual.latitude;
        _longitude = manual.longitude;
        _manualLocationName = manual.name;
        _usingDefaultLocation = false;
        _locationState = LocationState.granted;
      });
      _recomputeTimesAndQibla();
    } else if (result is UseGpsLocation) {
      await _prefs.clearManualLocation();
      setState(() {
        _manualLocationName = null;
        _usingDefaultLocation = false;
      });
      await _refreshLocation();
    }
  }

  void _onLanguageChanged(String code) {
    setState(() => _language = code);
    _prefs.setLanguage(code);
    widget.onLocaleChanged(Locale(code));
    _recomputeTimesAndQibla();
  }

  void _onTimeFormatChanged(bool use24Hour) {
    setState(() => _use24HourFormat = use24Hour);
    _prefs.setUse24HourFormat(use24Hour);
    _recomputeTimesAndQibla();
  }

  void _onCalculationMethodChanged(String method) {
    setState(() => _calculationMethod = method);
    _prefs.setCalculationMethod(method);
    _recomputeTimesAndQibla();
  }

  void _onMadhabChanged(String madhab) {
    setState(() => _madhab = madhab);
    _prefs.setMadhab(madhab);
    _recomputeTimesAndQibla();
  }

  void _onAppearanceModeChanged(String mode) {
    setState(() => _appearanceMode = mode);
    _prefs.setAppearanceMode(mode);
    _applyAppearance();
  }

  void _onWeekStartChanged(int weekStart) {
    setState(() => _weekStart = weekStart);
    _prefs.setWeekStart(weekStart);
  }

  void _onNotificationsEnabledChanged(bool enabled) {
    setState(() => _notificationsEnabled = enabled);
    _prefs.setNotificationsEnabled(enabled);
    final times = _prayerTimes;
    if (times == null) return;
    final today = DateTime.now();
    final upcomingDays = [
      for (var offset = 0; offset < 7; offset++)
        computePrayerTimes(
          latitude: _latitude!,
          longitude: _longitude!,
          date: today.add(Duration(days: offset)),
          methodKey: _calculationMethod,
          madhabKey: _madhab,
        ),
    ];
    _rescheduleNotifications(upcomingDays);
  }

  Future<void> _openNotificationGrid() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NotificationGridScreen(
          language: _language,
          weekStart: _weekStart,
        ),
      ),
    );
    // The grid persists directly to PrefsService; re-derive the schedule
    // with whatever the user changed once they come back.
    final times = _prayerTimes;
    if (times == null || _latitude == null || _longitude == null) return;
    final today = DateTime.now();
    final upcomingDays = [
      for (var offset = 0; offset < 7; offset++)
        computePrayerTimes(
          latitude: _latitude!,
          longitude: _longitude!,
          date: today.add(Duration(days: offset)),
          methodKey: _calculationMethod,
          madhabKey: _madhab,
        ),
    ];
    _rescheduleNotifications(upcomingDays);
  }

  @override
  Widget build(BuildContext context) {
    final locationLabel = _manualLocationName ??
        AppStrings.of(
          context,
          _usingDefaultLocation ? 'defaultLocationName' : 'currentLocationLabel',
        );

    final screens = [
      PrayerTimesScreen(
        locationState: _locationState,
        times: _prayerTimes,
        language: _language,
        use24HourFormat: _use24HourFormat,
        onRetryLocation: _refreshLocation,
      ),
      QiblaScreen(
        locationState: _locationState,
        qiblaBearing: _qiblaBearing,
        language: _language,
        onRetryLocation: _refreshLocation,
      ),
      SettingsScreen(
        language: _language,
        use24HourFormat: _use24HourFormat,
        calculationMethod: _calculationMethod,
        madhab: _madhab,
        locationLabel: locationLabel,
        appearanceMode: _appearanceMode,
        weekStart: _weekStart,
        notificationsEnabled: _notificationsEnabled,
        onLanguageChanged: _onLanguageChanged,
        onTimeFormatChanged: _onTimeFormatChanged,
        onCalculationMethodChanged: _onCalculationMethodChanged,
        onMadhabChanged: _onMadhabChanged,
        onChangeLocation: _openLocationPicker,
        onAppearanceModeChanged: _onAppearanceModeChanged,
        onWeekStartChanged: _onWeekStartChanged,
        onNotificationsEnabledChanged: _onNotificationsEnabledChanged,
        onCustomizeByDay: _openNotificationGrid,
      ),
    ];

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Stack(
          alignment: AlignmentDirectional.centerStart,
          children: [
            PositionedDirectional(
              top: 6,
              bottom: 6,
              start: -2,
              width: 96,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  // AppTheme.accent300 (0xFFDDA875) at 40% alpha.
                  color: Color(0x66DDA875),
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 2),
              child: Text(AppStrings.of(context, 'appName')),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: theme.colorScheme.outline,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: InkWell(
              onTap: _openLocationPicker,
              borderRadius: const BorderRadius.all(Radius.circular(AppTheme.radiusPill)),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border.all(color: theme.colorScheme.outline),
                  borderRadius: const BorderRadius.all(Radius.circular(AppTheme.radiusPill)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.place_rounded,
                        size: 18, color: AppTheme.accent700),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        locationLabel,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium,
                      ),
                    ),
                    Text(
                      AppStrings.of(context, 'change'),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.accent700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: StarWatermark()),
          IndexedStack(index: _tabIndex, children: screens),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.access_time_rounded),
            label: AppStrings.of(context, 'tabPrayerTimes'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.explore_rounded),
            label: AppStrings.of(context, 'tabQibla'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_rounded),
            label: AppStrings.of(context, 'tabSettings'),
          ),
        ],
      ),
    );
  }
}

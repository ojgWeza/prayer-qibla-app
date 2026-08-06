import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../services/geocoding_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/prayer_times_service.dart';
import '../services/prefs_service.dart';
import '../services/widget_service.dart';
import '../widgets/star_watermark.dart';
import 'city_search_screen.dart';
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

  const HomeShell({super.key, required this.onLocaleChanged});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _prefs = PrefsService();
  final _locationService = LocationService();
  final _notificationService = NotificationService();

  int _tabIndex = 0;

  LocationState _locationState = LocationState.denied;
  double? _latitude;
  double? _longitude;
  DailyPrayerTimes? _prayerTimes;
  double? _qiblaBearing;

  /// Name of the manually picked city, or null while using GPS.
  String? _manualLocationName;

  String _language = 'ar';
  bool _use24HourFormat = true;
  String _calculationMethod = 'egyptian';
  String _madhab = 'shafi';

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    _language = await _prefs.getLanguage();
    _use24HourFormat = await _prefs.getUse24HourFormat();
    _calculationMethod = await _prefs.getCalculationMethod();
    _madhab = await _prefs.getMadhab();
    if (mounted) {
      widget.onLocaleChanged(Locale(_language));
      setState(() {});
    }

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
    _manualLocationName = AppStrings.forLanguage(_language, 'defaultLocationName');
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
    });

    _notificationService.scheduleUpcoming(
      upcomingDays,
      // Per-day/per-prayer muting was removed pending a redesign (see
      // TODO.md) -- every notifiable prayer fires for now.
      isEnabled: (weekday, prayer) => true,
      labelFor: (key) => AppStrings.forLanguage(_language, key),
    );

    updateNextPrayerWidget(
      upcomingDays: upcomingDays,
      language: _language,
      use24HourFormat: _use24HourFormat,
    );
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
        _locationState = LocationState.granted;
      });
      _recomputeTimesAndQibla();
    } else if (result is UseGpsLocation) {
      await _prefs.clearManualLocation();
      setState(() => _manualLocationName = null);
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

  @override
  Widget build(BuildContext context) {
    final locationLabel = _manualLocationName ??
        AppStrings.of(context, 'currentLocationLabel');

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
        onRetryLocation: _refreshLocation,
      ),
      SettingsScreen(
        language: _language,
        use24HourFormat: _use24HourFormat,
        calculationMethod: _calculationMethod,
        madhab: _madhab,
        locationLabel: locationLabel,
        onLanguageChanged: _onLanguageChanged,
        onTimeFormatChanged: _onTimeFormatChanged,
        onCalculationMethodChanged: _onCalculationMethodChanged,
        onMadhabChanged: _onMadhabChanged,
        onChangeLocation: _openLocationPicker,
      ),
    ];

    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.of(context, 'appName')),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: InkWell(
              onTap: _openLocationPicker,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              child: Row(
                children: [
                  Icon(Icons.place_outlined, size: 18, color: onPrimary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      locationLabel,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: onPrimary),
                    ),
                  ),
                  Text(
                    AppStrings.of(context, 'change'),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: onPrimary.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
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
            icon: const Icon(Icons.access_time),
            label: AppStrings.of(context, 'tabPrayerTimes'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.explore),
            label: AppStrings.of(context, 'tabQibla'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings),
            label: AppStrings.of(context, 'tabSettings'),
          ),
        ],
      ),
    );
  }
}

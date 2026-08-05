import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../services/geocoding_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/prayer_times_service.dart';
import '../services/prefs_service.dart';
import 'city_search_screen.dart';
import 'prayer_times_screen.dart';
import 'qibla_screen.dart';
import 'settings_screen.dart';

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
  String _calculationMethod = 'egyptian';
  String _madhab = 'shafi';
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    _language = await _prefs.getLanguage();
    _calculationMethod = await _prefs.getCalculationMethod();
    _madhab = await _prefs.getMadhab();
    _notificationsEnabled = await _prefs.getNotificationsEnabled();
    if (mounted) {
      widget.onLocaleChanged(Locale(_language));
      setState(() {});
    }

    await _notificationService.init();
    if (_notificationsEnabled) {
      await _notificationService.requestPermission();
    }

    final manual = await _prefs.getManualLocation();
    if (manual != null) {
      _latitude = manual.latitude;
      _longitude = manual.longitude;
      _manualLocationName = manual.name;
      if (mounted) setState(() => _locationState = LocationState.granted);
      _recomputeTimesAndQibla();
    } else {
      await _refreshLocation();
    }
  }

  Future<void> _refreshLocation() async {
    final result = await _locationService.getCurrentLocation();
    if (!mounted) return;
    setState(() => _locationState = result.state);
    final position = result.position;
    if (position == null) return;

    _latitude = position.latitude;
    _longitude = position.longitude;
    _recomputeTimesAndQibla();
  }

  void _recomputeTimesAndQibla() {
    final lat = _latitude;
    final lng = _longitude;
    if (lat == null || lng == null) return;

    final times = computePrayerTimes(
      latitude: lat,
      longitude: lng,
      date: DateTime.now(),
      methodKey: _calculationMethod,
      madhabKey: _madhab,
    );
    final bearing = computeQiblaBearing(latitude: lat, longitude: lng);

    setState(() {
      _prayerTimes = times;
      _qiblaBearing = bearing;
    });

    if (_notificationsEnabled) {
      _notificationService.scheduleForToday(
        times,
        labelFor: (key) => AppStrings.forLanguage(_language, key),
      );
    } else {
      _notificationService.cancelAll();
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

  Future<void> _onNotificationsChanged(bool enabled) async {
    setState(() => _notificationsEnabled = enabled);
    await _prefs.setNotificationsEnabled(enabled);
    if (enabled) {
      await _notificationService.requestPermission();
      _recomputeTimesAndQibla();
    } else {
      await _notificationService.cancelAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationLabel = _manualLocationName ??
        AppStrings.of(context, 'currentLocationLabel');

    final screens = [
      PrayerTimesScreen(
        locationState: _locationState,
        times: _prayerTimes,
        onRetryLocation: _refreshLocation,
      ),
      QiblaScreen(
        locationState: _locationState,
        qiblaBearing: _qiblaBearing,
        onRetryLocation: _refreshLocation,
      ),
      SettingsScreen(
        language: _language,
        calculationMethod: _calculationMethod,
        madhab: _madhab,
        notificationsEnabled: _notificationsEnabled,
        locationLabel: locationLabel,
        onLanguageChanged: _onLanguageChanged,
        onCalculationMethodChanged: _onCalculationMethodChanged,
        onMadhabChanged: _onMadhabChanged,
        onNotificationsChanged: _onNotificationsChanged,
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
      body: IndexedStack(index: _tabIndex, children: screens),
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

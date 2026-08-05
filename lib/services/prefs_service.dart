import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around SharedPreferences for the handful of settings this
/// app persists locally (no backend, everything stays on-device).
class PrefsService {
  static const _keyLanguage = 'language_code';
  static const _keyUse24HourFormat = 'use_24_hour_format';
  static const _keyCalculationMethod = 'calculation_method';
  static const _keyMadhab = 'madhab';
  static const _keyManualLat = 'manual_location_lat';
  static const _keyManualLon = 'manual_location_lon';
  static const _keyManualName = 'manual_location_name';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<String> getLanguage() async =>
      (await _prefs).getString(_keyLanguage) ?? 'ar';

  Future<void> setLanguage(String code) async =>
      (await _prefs).setString(_keyLanguage, code);

  Future<bool> getUse24HourFormat() async =>
      (await _prefs).getBool(_keyUse24HourFormat) ?? true;

  Future<void> setUse24HourFormat(bool use24Hour) async =>
      (await _prefs).setBool(_keyUse24HourFormat, use24Hour);

  Future<String> getCalculationMethod() async =>
      (await _prefs).getString(_keyCalculationMethod) ?? 'egyptian';

  Future<void> setCalculationMethod(String method) async =>
      (await _prefs).setString(_keyCalculationMethod, method);

  Future<String> getMadhab() async =>
      (await _prefs).getString(_keyMadhab) ?? 'shafi';

  Future<void> setMadhab(String madhab) async =>
      (await _prefs).setString(_keyMadhab, madhab);

  /// A manually picked city overrides GPS location until cleared.
  Future<ManualLocation?> getManualLocation() async {
    final prefs = await _prefs;
    final lat = prefs.getDouble(_keyManualLat);
    final lon = prefs.getDouble(_keyManualLon);
    final name = prefs.getString(_keyManualName);
    if (lat == null || lon == null || name == null) return null;
    return ManualLocation(name: name, latitude: lat, longitude: lon);
  }

  Future<void> setManualLocation(ManualLocation location) async {
    final prefs = await _prefs;
    await prefs.setDouble(_keyManualLat, location.latitude);
    await prefs.setDouble(_keyManualLon, location.longitude);
    await prefs.setString(_keyManualName, location.name);
  }

  Future<void> clearManualLocation() async {
    final prefs = await _prefs;
    await prefs.remove(_keyManualLat);
    await prefs.remove(_keyManualLon);
    await prefs.remove(_keyManualName);
  }
}

class ManualLocation {
  final String name;
  final double latitude;
  final double longitude;

  const ManualLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

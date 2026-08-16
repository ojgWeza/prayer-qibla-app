import 'package:adhan_dart/adhan_dart.dart';
import 'package:lat_lng_to_timezone/lat_lng_to_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class DailyPrayerTimes {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  const DailyPrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  List<MapEntry<String, DateTime>> get ordered => [
        MapEntry('fajr', fajr),
        MapEntry('sunrise', sunrise),
        MapEntry('dhuhr', dhuhr),
        MapEntry('asr', asr),
        MapEntry('maghrib', maghrib),
        MapEntry('isha', isha),
      ];
}

/// Maps our persisted setting strings to adhan_dart's calculation methods.
CalculationParameters resolveCalculationParameters({
  required String methodKey,
  required String madhabKey,
}) {
  final CalculationParameters params = switch (methodKey) {
    'egyptian' => CalculationMethodParameters.egyptian(),
    'karachi' => CalculationMethodParameters.karachi(),
    'muslimWorldLeague' => CalculationMethodParameters.muslimWorldLeague(),
    'northAmerica' => CalculationMethodParameters.northAmerica(),
    'ummAlQura' => CalculationMethodParameters.ummAlQura(),
    'kuwait' => CalculationMethodParameters.kuwait(),
    'qatar' => CalculationMethodParameters.qatar(),
    'singapore' => CalculationMethodParameters.singapore(),
    'turkiye' => CalculationMethodParameters.turkiye(),
    'tehran' => CalculationMethodParameters.tehran(),
    'dubai' => CalculationMethodParameters.dubai(),
    'moonsightingCommittee' =>
      CalculationMethodParameters.moonsightingCommittee(),
    _ => CalculationMethodParameters.egyptian(),
  };
  params.madhab = madhabKey == 'hanafi' ? Madhab.hanafi : Madhab.shafi;
  return params;
}

DailyPrayerTimes computePrayerTimes({
  required double latitude,
  required double longitude,
  required DateTime date,
  required String methodKey,
  required String madhabKey,
}) {
  final coordinates = Coordinates(latitude, longitude);
  final params = resolveCalculationParameters(
    methodKey: methodKey,
    madhabKey: madhabKey,
  );
  final times = PrayerTimes(
    date: date,
    coordinates: coordinates,
    calculationParameters: params,
  );
  // adhan_dart returns UTC-flagged DateTimes that are correct absolute
  // instants (see its TimeComponents.dart) -- render them in the *prayer
  // location's own* timezone, not the device's, so a manually-searched
  // distant city shows its own local prayer times instead of the device's
  // (comparisons like `.isAfter()`/`.difference()` elsewhere stay correct
  // either way, since those operate on the absolute instant regardless of
  // which zone a DateTime/TZDateTime is labeled with).
  final location = _resolveDisplayLocation(latitude, longitude);
  DateTime toDisplay(DateTime utcInstant) => location == null
      ? utcInstant.toLocal()
      : tz.TZDateTime.from(utcInstant, location);
  return DailyPrayerTimes(
    fajr: toDisplay(times.fajr),
    sunrise: toDisplay(times.sunrise),
    dhuhr: toDisplay(times.dhuhr),
    asr: toDisplay(times.asr),
    maghrib: toDisplay(times.maghrib),
    isha: toDisplay(times.isha),
  );
}

bool _tzDataInitialized = false;

/// Resolves the IANA timezone the given coordinates actually sit in, purely
/// offline (`lat_lng_to_timezone`'s hardcoded polygon lookup + the bundled
/// `timezone` package's zone database -- no network call). Falls back to
/// null (meaning "use the device's own timezone") when the coordinates fall
/// outside the lookup's coverage.
tz.Location? _resolveDisplayLocation(double latitude, double longitude) {
  final zoneName = latLngToTimezoneString(latitude, longitude);
  if (zoneName == 'unknown') return null;
  if (!_tzDataInitialized) {
    tz_data.initializeTimeZones();
    _tzDataInitialized = true;
  }
  try {
    return tz.getLocation(zoneName);
  } catch (_) {
    return null;
  }
}

double computeQiblaBearing({required double latitude, required double longitude}) {
  return Qibla.qibla(Coordinates(latitude, longitude));
}

/// The 5 obligatory prayers notifications can be scheduled for.
/// Sunrise is excluded — it isn't a prayer time.
const List<String> notifiablePrayers = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];

const List<String> availableCalculationMethods = [
  'egyptian',
  'muslimWorldLeague',
  'ummAlQura',
  'karachi',
  'northAmerica',
  'kuwait',
  'qatar',
  'singapore',
  'turkiye',
  'tehran',
  'dubai',
  'moonsightingCommittee',
];

import 'package:adhan_dart/adhan_dart.dart';

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
  return DailyPrayerTimes(
    fajr: times.fajr,
    sunrise: times.sunrise,
    dhuhr: times.dhuhr,
    asr: times.asr,
    maghrib: times.maghrib,
    isha: times.isha,
  );
}

double computeQiblaBearing({required double latitude, required double longitude}) {
  return Qibla.qibla(Coordinates(latitude, longitude));
}

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

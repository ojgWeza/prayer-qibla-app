import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'screens/home_shell.dart';
import 'services/ad_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdService().init();
  if (kDebugMode) {
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: <String>[]),
    );
  }
  runApp(const PrayerQiblaApp());
}

class PrayerQiblaApp extends StatefulWidget {
  const PrayerQiblaApp({super.key});

  @override
  State<PrayerQiblaApp> createState() => _PrayerQiblaAppState();
}

class _PrayerQiblaAppState extends State<PrayerQiblaApp> {
  Locale _locale = const Locale('ar');

  void _setLocale(Locale locale) {
    if (locale == _locale) return;
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: HomeShell(onLocaleChanged: _setLocale),
    );
  }
}

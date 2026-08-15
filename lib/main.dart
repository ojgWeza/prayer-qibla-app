import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'screens/home_shell.dart';
import 'services/ad_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdService().init();
  // google_mobile_ads has no web implementation -- AdMob is Android/iOS
  // only for this app.
  if (kDebugMode && !kIsWeb) {
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
  ThemeMode _themeMode = ThemeMode.system;

  void _setLocale(Locale locale) {
    if (locale == _locale) return;
    setState(() => _locale = locale);
  }

  void _setThemeMode(ThemeMode mode) {
    if (mode == _themeMode) return;
    setState(() => _themeMode = mode);
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
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode,
      // Default curve is linear; easeInOut reads less mechanical for the one
      // moment the whole screen recolors (the afterMaghrib auto dark-mode
      // flip).
      themeAnimationCurve: Curves.easeInOut,
      home: HomeShell(
        onLocaleChanged: _setLocale,
        onThemeModeChanged: _setThemeMode,
      ),
    );
  }
}

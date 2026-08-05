import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Central place for AdMob ad unit ids.
///
/// TODO: replace the test ids below with your real AdMob ad unit ids
/// before publishing to the Play Store. Test ids are Google's public
/// placeholders and always serve test creatives.
class AdIds {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/6300978111';
    return 'ca-app-pub-3940256099942544/2934735716'; // iOS test banner
  }
}

class AdService {
  Future<void> init() => MobileAds.instance.initialize();
}

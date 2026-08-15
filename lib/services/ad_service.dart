import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Central place for AdMob ad unit ids.
///
/// TODO: replace the test ids below with your real AdMob ad unit ids
/// before publishing to the Play Store. Test ids are Google's public
/// placeholders and always serve test creatives.
class AdIds {
  static String get bannerAdUnitId {
    if (!kIsWeb && Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    }
    return 'ca-app-pub-3940256099942544/2934735716'; // iOS test banner
  }
}

class AdService {
  // google_mobile_ads has no web implementation -- AdMob is Android/iOS
  // only for this app; skip init on web instead of throwing before
  // runApp() ever gets a chance to render.
  Future<void> init() async {
    if (kIsWeb) return;
    await MobileAds.instance.initialize();
  }
}

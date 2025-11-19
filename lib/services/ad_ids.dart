// lib/services/ad_ids.dart
import 'package:flutter/foundation.dart' show kReleaseMode, defaultTargetPlatform, TargetPlatform;

class AdIds {
  // ====== App IDs (AdMob) ======
  // ANDROID — SEU App ID real:
  static const String androidAppIdProd = 'ca-app-pub-1617498034054306~4046901303';
  // iOS — SEU App ID real:
  static const String iosAppIdProd     = 'ca-app-pub-1617498034054306~9323725820';

  // ====== Unit IDs (blocos de anúncios) ======
  // ANDROID — seus blocos reais:
  static const String androidBannerProd       = 'ca-app-pub-1617498034054306/6885458262'; // banner_home_bottom
  static const String androidInterstitialProd = 'ca-app-pub-1617498034054306/9446180606'; // interstitial_nav
  static const String androidRewardedProd     = 'ca-app-pub-1617498034054306/6820017265'; // rewarded_premium_24h

  // iOS — seus blocos reais:
  static const String iosBannerProd       = 'ca-app-pub-1617498034054306/8489543348'; // banner_home_bottom_ios
  static const String iosInterstitialProd = 'ca-app-pub-1617498034054306/5504287350'; // interstitial_nav_ios
  static const String iosRewardedProd     = 'ca-app-pub-1617498034054306/5387903137'; // rewarded_premium_24h_ios

  // ====== IDs de TESTE (Google) ======
  static const String androidAppIdTest = 'ca-app-pub-3940256099942544~3347511713';
  static const String iosAppIdTest     = 'ca-app-pub-3940256099942544~1458002511';

  static const String androidBannerTest       = 'ca-app-pub-3940256099942544/6300978111';
  static const String androidInterstitialTest = 'ca-app-pub-3940256099942544/1033173712';
  static const String androidRewardedTest     = 'ca-app-pub-3940256099942544/5224354917';

  static const String iosBannerTest       = 'ca-app-pub-3940256099942544/2934735716';
  static const String iosInterstitialTest = 'ca-app-pub-3940256099942544/4411468910';
  static const String iosRewardedTest     = 'ca-app-pub-3940256099942544/1712485313';

  // ====== Comportamento ======
  /// Deixe `false` no dev. Coloque `true` se quiser forçar IDs reais também no debug.
  static const bool kUseRealIdsInDebug = false;

  static bool get _useReal => kReleaseMode || kUseRealIdsInDebug;
  static bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

  // ====== App ID (referência para Manifest/Info.plist) ======
  static String appId() {
    if (_useReal) {
      return _isAndroid ? androidAppIdProd : iosAppIdProd;
    } else {
      return _isAndroid ? androidAppIdTest : iosAppIdTest;
    }
  }

  // ====== Unit IDs (usados pelo AdService) ======
  static String banner() {
    if (_useReal) {
      return _isAndroid ? androidBannerProd : iosBannerProd;
    } else {
      return _isAndroid ? androidBannerTest : iosBannerTest;
    }
  }

  static String interstitial() {
    if (_useReal) {
      return _isAndroid ? androidInterstitialProd : iosInterstitialProd;
    } else {
      return _isAndroid ? androidInterstitialTest : iosInterstitialTest;
    }
  }

  static String rewarded() {
    if (_useReal) {
      return _isAndroid ? androidRewardedProd : iosRewardedProd;
    } else {
      return _isAndroid ? androidRewardedTest : iosRewardedTest;
    }
  }
}

// lib/services/ad_service.dart
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:defense_ai/core/session.dart';             // checar Premium
import 'package:defense_ai/services/consent_service.dart'; // consentimento
import 'package:defense_ai/services/ad_ids.dart';           // IDs centralizados
import 'package:defense_ai/services/ad_policy.dart';        // política de frequência

/// Serviço central de anúncios (Android/iOS).
/// Seguro para projetos que também rodam na Web (não inicializa/usa ads na Web).
class AdService {
  // ======== AdUnit IDs (via AdIds) ========
  static String get bannerAdUnitId       => AdIds.banner();
  static String get interstitialAdUnitId => AdIds.interstitial();
  static String get rewardedAdUnitId     => AdIds.rewarded();

  // ============ Inicialização ============
  static Future<void> initialize() async {
    if (kIsWeb) return; // nada a fazer na Web
    await MobileAds.instance.initialize();

    // Sempre use test devices durante desenvolvimento
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: <String>['EMULATOR']),
    );
    debugPrint('[AdService] MobileAds inicializado + testDeviceIds configurado');
  }

  // ============ AdRequest central (respeita ConsentService) ============
  static AdRequest _adRequest() {
    final personalized = ConsentService.isPersonalized;
    // Quando NÃO personalizado, o SDK respeita nonPersonalizedAds / npa=1
    return AdRequest(
      nonPersonalizedAds: !personalized,
      extras: personalized ? null : const {'npa': '1'},
    );
  }

  // ============ Banner ============
  static BannerAd createBannerAd({
    AdSize size = AdSize.banner,
    void Function(Ad)? onLoaded,
    void Function(Ad, LoadAdError)? onFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: size,
      request: _adRequest(), // ← respeita consentimento
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint(
            '[AdService] Banner carregado: ${ad.adUnitId} (${size.width}x${size.height})',
          );
          onLoaded?.call(ad);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('[AdService] Falha ao carregar banner: $error');
          ad.dispose();
          onFailedToLoad?.call(ad, error);
        },
      ),
    );
  }

  // ============ Interstitial ============
  static InterstitialAd? _interstitialAd;
  static bool _isInterstitialReady = false;

  static void loadInterstitialAd() {
    if (kIsWeb) return;
    if (Session.isPremium) return; // premium não precisa carregar
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: _adRequest(), // ← respeita consentimento
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialReady = true;
          debugPrint('[AdService] Interstitial pronto');
        },
        onAdFailedToLoad: (error) {
          _isInterstitialReady = false;
          _interstitialAd = null;
          debugPrint('[AdService] Falha ao carregar interstitial: $error');
        },
      ),
    );
  }

  static bool get isInterstitialReady => _isInterstitialReady;

  /// Exibe independentemente de política. Use com cuidado.
  static void showInterstitialAd() {
    if (!_isInterstitialReady || _interstitialAd == null) return;
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        debugPrint('[AdService] Interstitial fechado — recarregando…');
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdService] Erro ao exibir interstitial: $error');
        ad.dispose();
        loadInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _isInterstitialReady = false;
  }

  /// Tenta exibir levando em conta:
  /// - Premium (não mostra)
  /// - Política de frequência (tempo + nº de telas)
  /// - Disponibilidade do anúncio (pré-carregado)
  static void maybeShowInterstitial() {
    if (kIsWeb) return;
    if (Session.isPremium) return;
    if (!AdPolicy.canShowNow()) {
      debugPrint('[AdService] Interstitial bloqueado pela política (cooldown).');
      return;
    }
    if (!_isInterstitialReady || _interstitialAd == null) {
      debugPrint('[AdService] Interstitial não pronto.');
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        AdPolicy.markShownNow(); // marca o momento da exibição
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        debugPrint('[AdService] Interstitial fechado — recarregando…');
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdService] Erro ao exibir interstitial: $error');
        ad.dispose();
        loadInterstitialAd();
      },
    );

    _interstitialAd!.show();
    _isInterstitialReady = false;
  }

  // ============ Rewarded ============
  static RewardedAd? _rewardedAd;
  static bool _isRewardedReady = false;

  static void loadRewardedAd() {
    if (kIsWeb) return;
    if (Session.isPremium) return; // opcional: se premium não precisa rewarded
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: _adRequest(), // ← respeita consentimento
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedReady = true;
          debugPrint('[AdService] Rewarded pronto');
        },
        onAdFailedToLoad: (error) {
          _isRewardedReady = false;
          _rewardedAd = null;
          debugPrint('[AdService] Falha ao carregar rewarded: $error');
        },
      ),
    );
  }

  static bool get isRewardedReady => _isRewardedReady;

  static void showRewardedAd({required Function() onRewarded}) {
    if (!_isRewardedReady || _rewardedAd == null) return;
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        debugPrint('[AdService] Rewarded fechado — recarregando…');
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdService] Erro ao exibir rewarded: $error');
        ad.dispose();
        loadRewardedAd();
      },
    );
    _rewardedAd!.show(onUserEarnedReward: (_, __) => onRewarded());
    _isRewardedReady = false;
  }
}

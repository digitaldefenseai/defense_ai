// lib/services/ad_manager.dart
import 'package:flutter/foundation.dart' show kIsWeb, VoidCallback, debugPrint;
import 'package:defense_ai/services/ad_service.dart';

/// Fachada fina para carregar/exibir anúncios.
/// - Mantém a API estável mesmo que AdService mude.
/// - Aplica limite de frequência (cooldown) para Interstitial.
class AdManager {
  // ===== Interstitial =====
  static DateTime? _lastInterstitialAt;
  static Duration _minGap = const Duration(minutes: 2); // intervalo mínimo padrão

  /// Opcional: ajuste o intervalo mínimo entre interstitials em runtime.
  static void setMinGap(Duration gap) {
    _minGap = gap;
  }

  /// Carrega um interstitial (pré-carregamento).
  static void loadInterstitial() {
    if (kIsWeb) return;
    AdService.loadInterstitialAd();
  }

  static bool get isInterstitialReady => AdService.isInterstitialReady;

  /// Retorna se PODE mostrar agora (ready + respeita cooldown).
  static bool canShowInterstitial() {
    if (kIsWeb) return false;
    if (!AdService.isInterstitialReady) return false;
    final now = DateTime.now();
    if (_lastInterstitialAt != null &&
        now.difference(_lastInterstitialAt!) < _minGap) {
      return false;
    }
    return true;
  }

  /// Exibe o interstitial se possível. Retorna true se exibiu.
  static bool tryShowInterstitial() {
    if (!canShowInterstitial()) {
      debugPrint('[AdManager] Interstitial bloqueado (ready=${AdService.isInterstitialReady}, '
          'cooldown=${_cooldownRemainingString()})');
      return false;
    }
    AdService.showInterstitialAd();
    _lastInterstitialAt = DateTime.now();
    return true;
  }

  /// API compatível com chamadas antigas (não retorna bool).
  static void showInterstitial() {
    tryShowInterstitial();
  }

  static String _cooldownRemainingString() {
    if (_lastInterstitialAt == null) return '0s';
    final elapsed = DateTime.now().difference(_lastInterstitialAt!);
    final remaining = _minGap - elapsed;
    if (remaining.isNegative) return '0s';
    if (remaining.inMinutes >= 1) return '${remaining.inMinutes}m';
    return '${remaining.inSeconds}s';
  }

  // ===== Rewarded =====
  static void loadRewarded() {
    if (kIsWeb) return;
    AdService.loadRewardedAd();
  }

  static bool get isRewardedReady => AdService.isRewardedReady;

  static void showRewarded({required VoidCallback onRewarded}) {
    if (kIsWeb) return;
    if (!AdService.isRewardedReady) {
      debugPrint('[AdManager] Rewarded não pronto');
      return;
    }
    AdService.showRewardedAd(onRewarded: onRewarded);
  }
}

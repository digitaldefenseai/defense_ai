// lib/services/ad_policy.dart
import 'dart:developer' as dev;

/// Regras centrais para exibir interstitials:
/// - Espera um mínimo de tempo entre exibições
/// - Espera um mínimo de telas navegadas entre exibições
class AdPolicy {
  // ===== Ajuste aqui conforme sua estratégia =====
  static const int minSecondsBetween = 90;   // tempo mínimo entre interstitials
  static const int minScreensBetween = 3;    // nº mínimo de navegações entre interstitials

  static DateTime? _lastShownAt;
  static int _screensSinceLast = minScreensBetween; // começa liberado após N telas

  /// Deve ser chamado a cada navegação relevante (ex.: pushNamed/pushReplacementNamed).
  static void onNavigation() {
    _screensSinceLast += 1;
    dev.log('[AdPolicy] screensSinceLast=$_screensSinceLast');
  }

  /// Reseta contadores (use se quiser ao voltar do background, por ex.).
  static void resetCounters() {
    _screensSinceLast = 0;
  }

  /// Informa que um interstitial foi exibido.
  static void markShownNow() {
    _lastShownAt = DateTime.now();
    _screensSinceLast = 0;
    dev.log('[AdPolicy] markShownNow at=$_lastShownAt');
  }

  /// Verifica se podemos exibir agora.
  static bool canShowNow() {
    // Regra de telas navegadas
    if (_screensSinceLast < minScreensBetween) {
      return false;
    }
    // Regra de tempo mínimo
    if (_lastShownAt != null) {
      final secs = DateTime.now().difference(_lastShownAt!).inSeconds;
      if (secs < minSecondsBetween) return false;
    }
    return true;
  }
}

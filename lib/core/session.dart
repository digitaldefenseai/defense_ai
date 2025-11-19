// lib/core/session.dart
import 'package:flutter/foundation.dart'; // ValueNotifier
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as dev;

// +++ NOVO: fonte de tempo injetável (relógio do sistema ou do servidor)
import 'package:defense_ai/core/time_source.dart';

/// Tipos de plano premium que o app pode exibir no UI.
enum PremiumPlan {
  monthly,      // Mensal
  semiannual,   // Semestral (6 meses)
  annual,       // Anual (12 meses)
  temporary,    // Temporário (ex.: 24h via anúncio recompensado)
}

class Session {
  static const _kPremiumUntilMs = 'premium_until_epoch_ms';
  static const _kPremiumPlan = 'premium_plan';

  // +++ NOVO: persistência do drift (ms)
  static const _kTimeDriftMs = 'time_drift_ms';

  static DateTime? _premiumUntil;
  static PremiumPlan? _premiumPlan;

  /// ===== Fonte de tempo (padrão: relógio local) =====
  static TimeSource timeSource = SystemTimeSource();
  static DateTime _now() => timeSource.now();

  /// Notificador global: toda mudança em premium dispara rebuilds na UI.
  static final ValueNotifier<int> premiumVersion = ValueNotifier<int>(0);
  static void _bump([String where = '']) {
    premiumVersion.value++;
    dev.log('[Session] bump -> ${premiumVersion.value} ($where)');
  }

  /// Carrega do storage e faz limpeza se expirado.
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // 1) Carrega drift persistido (se houver) e aplica como fonte de tempo
    final driftMs = prefs.getInt(_kTimeDriftMs);
    if (driftMs != null) {
      final drift = Duration(milliseconds: driftMs);
      timeSource = DriftedServerTimeSource(drift: drift);
      dev.log('[Session.init] loaded drift=$drift');
    } else {
      timeSource = SystemTimeSource();
      dev.log('[Session.init] using SystemTimeSource');
    }

    // 2) Carrega premium
    final ms = prefs.getInt(_kPremiumUntilMs);
    if (ms != null) {
      _premiumUntil = DateTime.fromMillisecondsSinceEpoch(ms);
    }

    final planStr = prefs.getString(_kPremiumPlan);
    _premiumPlan = _planFromString(planStr);

    dev.log('[Session.init] loaded until=$_premiumUntil plan=$_premiumPlan');

    // 3) Se expirou, limpa tudo.
    if (!isPremium) {
      await clearPremium();
    } else {
      _bump('init'); // garante que a UI veja o estado atual
    }
  }

  /// Está premium se agora < premiumUntil.
  static bool get isPremium =>
      _premiumUntil != null && _now().isBefore(_premiumUntil!);

  static DateTime? get premiumUntil => _premiumUntil;
  static PremiumPlan? get premiumPlan => _premiumPlan;

  /// Define premium com duração + tipo de plano.
  static Future<void> _setPremium(Duration duration, PremiumPlan plan) async {
    final until = _now().add(duration);
    _premiumUntil = until;
    _premiumPlan = plan;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kPremiumUntilMs, until.millisecondsSinceEpoch);
    await prefs.setString(_kPremiumPlan, _planToString(plan));

    dev.log('[Session._setPremium] plan=$plan until=$until');
    _bump('_setPremium');
  }

  /// API usada pelo anúncio recompensado (ex.: 24h).
  static Future<void> activateTempPremium(Duration duration) async {
    await _setPremium(duration, PremiumPlan.temporary);
  }

  /// Atalhos para planos pagos (placeholder IAP).
  static Future<void> activateMonthly() async {
    await _setPremium(const Duration(days: 30), PremiumPlan.monthly);
  }

  static Future<void> activateSemiannual() async {
    await _setPremium(const Duration(days: 180), PremiumPlan.semiannual);
  }

  static Future<void> activateAnnual() async {
    await _setPremium(const Duration(days: 365), PremiumPlan.annual);
  }

  /// Remove o premium (volta para Free).
  static Future<void> clearPremium() async {
    _premiumUntil = null;
    _premiumPlan = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPremiumUntilMs);
    await prefs.remove(_kPremiumPlan);
    dev.log('[Session.clearPremium] cleared');
    _bump('clearPremium');
  }

  // ------------ Helpers para UI (selo/legendas) ------------

  /// Rótulo do plano atual (ou "Básico" se não premium).
  static String currentPlanLabel() {
    if (!isPremium || _premiumPlan == null) return 'Nível 1 - Básico';
    switch (_premiumPlan!) {
      case PremiumPlan.monthly:
        return 'Premium Mensal';
      case PremiumPlan.semiannual:
        return 'Premium Semestral';
      case PremiumPlan.annual:
        return 'Premium Anual';
      case PremiumPlan.temporary:
        return 'Premium (temporário)';
    }
  }

  /// Tempo restante curto (ex.: "29d", "5h", "12min").
  static String remainingShort() {
    if (!isPremium || _premiumUntil == null) return '';
    final diff = _premiumUntil!.difference(_now());
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}min';
    return 'agora';
  }

  /// Ex.: "Premium Mensal — 29d" ou "Nível 1 - Básico".
  static String badgeText() {
    if (!isPremium) return 'Nível 1 - Básico';
    final label = currentPlanLabel();
    final rest = remainingShort();
    return rest.isEmpty ? label : '$label — $rest';
  }

  // ------------ Serialização simples do enum ------------
  static String _planToString(PremiumPlan plan) {
    switch (plan) {
      case PremiumPlan.monthly:
        return 'monthly';
      case PremiumPlan.semiannual:
        return 'semiannual';
      case PremiumPlan.annual:
        return 'annual';
      case PremiumPlan.temporary:
        return 'temporary';
    }
  }

  static PremiumPlan? _planFromString(String? s) {
    switch (s) {
      case 'monthly':
        return PremiumPlan.monthly;
      case 'semiannual':
        return PremiumPlan.semiannual;
      case 'annual':
        return PremiumPlan.annual;
      case 'temporary':
        return PremiumPlan.temporary;
      default:
        return null;
    }
  }

  // ------------ Integração com horário do servidor ------------
  /// Injeta horário de servidor (UTC recomendado) e PERSISTE o drift.
  static Future<void> setServerNowAndPersist(DateTime serverNowUtc) async {
    final serverUtc = serverNowUtc.toUtc();
    final clientUtc = DateTime.now().toUtc();
    final drift = serverUtc.difference(clientUtc); // pode ser positivo ou negativo

    timeSource = DriftedServerTimeSource(drift: drift);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kTimeDriftMs, drift.inMilliseconds);

    dev.log('[Session.setServerNowAndPersist] drift=$drift');
    _bump('setServerNowAndPersist');
  }

  /// Volta a usar o relógio local do dispositivo e remove o drift persistido.
  static Future<void> useSystemClock() async {
    timeSource = SystemTimeSource();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTimeDriftMs);
    dev.log('[Session.useSystemClock] using local time');
    _bump('useSystemClock');
  }
}

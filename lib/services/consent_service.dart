// lib/services/consent_service.dart
import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode, debugPrint;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Consentimento com UMP (User Messaging Platform):
/// - Detecta automaticamente EEA e mostra o formulário quando exigido.
/// - Persiste a decisão e expõe `isPersonalized` para o AdRequest.
/// - Em Web não faz nada (retorna imediatamente).
class ConsentService {
  static const _kPersonalizedKey = 'consent_personalized';
  static const _kLastStatusKey = 'consent_last_status';

  /// true = anúncios personalizados; false = não-personalizados (npa=1).
  static bool _isPersonalized = true;
  static ConsentStatus _lastStatus = ConsentStatus.unknown;

  static bool get isPersonalized => _isPersonalized;
  static ConsentStatus get lastStatus => _lastStatus;

  /// Carrega valores persistidos (sem UI).
  static Future<void> load() async {
    if (kIsWeb) return;
    final prefs = await SharedPreferences.getInstance();
    _isPersonalized = prefs.getBool(_kPersonalizedKey) ?? true;
    final raw = prefs.getInt(_kLastStatusKey);
    _lastStatus = ConsentStatus.values
        .firstWhere((e) => e.index == raw, orElse: () => ConsentStatus.unknown);
    debugPrint(
      '[ConsentService] load: personalized=$_isPersonalized, status=$_lastStatus',
    );
  }

  /// Mostra UI de consentimento se necessário (UMP).
  /// Pode ser chamado no boot (ex.: Splash) após `WidgetsBinding`.
  static Future<void> ensureConsentUI(BuildContext context) async {
    if (kIsWeb) return; // UMP não se aplica no Web

    try {
      // 1) Atualiza estado de consentimento (API nova usa callbacks)
      final params = ConsentRequestParameters(
        tagForUnderAgeOfConsent: false,
        consentDebugSettings: _debugSettingsIfNeeded(),
      );

      final completer = Completer<void>();

      ConsentInformation.instance.requestConsentInfoUpdate(
        params,
            () async {
          final status =
          await ConsentInformation.instance.getConsentStatus();
          final canRequestAds =
          await ConsentInformation.instance.canRequestAds();
          debugPrint(
            '[ConsentService] UMP status=$status canRequestAds=$canRequestAds',
          );

          // 2) Se houver formulário disponível, carregue e mostre se for obrigatório
          if (await ConsentInformation.instance.isConsentFormAvailable()) {
            await _loadAndShowFormIfRequired();
          } else {
            debugPrint(
              '[ConsentService] No form available (fora da EEA ou já consentido).',
            );
            // Mesmo sem form disponível, atualiza/persiste flags
            await _updateFromConsentInfoAndPersist();
          }

          completer.complete();
        },
            (FormError error) {
          debugPrint(
            '[ConsentService] requestConsentInfoUpdate error: ${error.message}',
          );
          // fallback: mantém valor já salvo (ou default = personalized true)
          completer.complete();
        },
      );

      await completer.future;
    } catch (e) {
      debugPrint('[ConsentService] ensureConsentUI error: $e');
      // fallback: mantém valor já salvo (ou default = personalized true)
    }
  }

  /// Carrega o formulário e mostra se o status exigir (required).
  static Future<void> _loadAndShowFormIfRequired() async {
    final completer = Completer<void>();

    ConsentForm.loadConsentForm(
          (ConsentForm consentForm) async {
        final status =
        await ConsentInformation.instance.getConsentStatus();

        if (status == ConsentStatus.required) {
          try {
            consentForm.show((FormError? formError) async {
              if (formError != null) {
                debugPrint(
                  '[ConsentService] Form show error: ${formError.message}',
                );
              }
              // Após o fechamento do form, lemos e persistimos o estado final
              await _updateFromConsentInfoAndPersist();
              completer.complete();
            });
          } catch (e) {
            debugPrint('[ConsentService] Form show exception: $e');
            await _updateFromConsentInfoAndPersist();
            completer.complete();
          }
        } else {
          // Form disponível mas não obrigatório
          await _updateFromConsentInfoAndPersist();
          completer.complete();
        }
      },
          (FormError formError) {
        debugPrint(
          '[ConsentService] loadConsentForm error: ${formError.message}',
        );
        // Não travamos o app, apenas seguimos com o último estado conhecido
        completer.complete();
      },
    );

    return completer.future;
  }

  /// Lê ConsentInformation e persiste flags (personalized x npa).
  static Future<void> _updateFromConsentInfoAndPersist() async {
    _lastStatus = await ConsentInformation.instance.getConsentStatus();

    // Regras simples:
    // obtained/notRequired -> personalizados true
    // required/unknown     -> conservador: não-personalizados (npa)
    switch (_lastStatus) {
      case ConsentStatus.obtained:
      case ConsentStatus.notRequired:
        _isPersonalized = true;
        break;
      case ConsentStatus.required:
      case ConsentStatus.unknown:
      default:
        _isPersonalized = false;
        break;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPersonalizedKey, _isPersonalized);
    await prefs.setInt(_kLastStatusKey, _lastStatus.index);

    debugPrint(
      '[ConsentService] persist → personalized=$_isPersonalized, status=$_lastStatus',
    );
  }

  /// Em debug, você pode forçar EEA e registrar devices de teste.
  static ConsentDebugSettings? _debugSettingsIfNeeded() {
    if (kReleaseMode) return null;
    return ConsentDebugSettings(
      debugGeography: DebugGeography.debugGeographyEea,
      testIdentifiers: <String>[
        // Adicione aqui o hashed device id do seu aparelho, se quiser testar.
      ],
    );
  }
}

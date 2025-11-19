// lib/core/att.dart
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

/// Solicita a permissão ATT (iOS 14+).
/// - Não faz nada no Android/Web.
/// - Chame antes de inicializar o AdMob para refletir nas preferências dos anúncios.
class ATT {
  /// Pede a permissão somente se ainda não foi determinada.
  static Future<void> requestIfNeeded() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return;

    final status = await AppTrackingTransparency.trackingAuthorizationStatus;

    if (status == TrackingStatus.notDetermined) {
      // (Opcional) pequeno delay para evitar conflito com o boot do app.
      await Future.delayed(const Duration(milliseconds: 300));
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  }

  /// Ajuda a consultar o status atual (útil para analytics/debug/UI).
  static Future<TrackingStatus> status() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return TrackingStatus.notSupported;
    }
    return AppTrackingTransparency.trackingAuthorizationStatus;
  }
}

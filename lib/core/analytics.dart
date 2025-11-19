import 'package:flutter/foundation.dart';

/// Camada fina de analytics.
/// Troque o corpo dos métodos para Firebase/Segment/Amplitude quando quiser.
class Analytics {
  static void screenView(String screen, {String? from}) {
    debugPrint('[analytics] screen_view: $screen (from: ${from ?? "-"})');
    // Exemplo Firebase:
    // await FirebaseAnalytics.instance.logScreenView(
    //   screenName: screen,
    //   screenClass: screen,
    // );
  }

  static void event(String name, {Map<String, Object?>? params}) {
    debugPrint('[analytics] event: $name ${params ?? {}}');
    // Exemplo Firebase:
    // await FirebaseAnalytics.instance.logEvent(name: name, parameters: params);
  }
}

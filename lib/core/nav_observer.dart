// lib/core/nav_observer.dart
import 'package:flutter/material.dart';
import 'package:defense_ai/core/analytics.dart';
import 'package:defense_ai/services/ad_policy.dart'; // ← adicionamos

/// Singleton para cadastrar no MaterialApp.navigatorObservers
final appNavObserver = AppNavObserver();

class AppNavObserver extends NavigatorObserver {
  String _name(Route<dynamic>? r) => r?.settings.name ?? 'unknown';

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    // Tela visível após o push é 'route'
    Analytics.screenView(_name(route), from: _name(previousRoute));
    AdPolicy.onNavigation(); // ← conta navegação para a política de interstitial
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    // Tela visível após replace é 'newRoute'
    Analytics.screenView(_name(newRoute), from: _name(oldRoute));
    AdPolicy.onNavigation(); // ← conta navegação
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    // Ao voltar, a tela visível é a previousRoute
    Analytics.screenView(_name(previousRoute), from: _name(route));
    AdPolicy.onNavigation(); // ← conta navegação
  }
}

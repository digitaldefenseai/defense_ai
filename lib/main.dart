// lib/main.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'package:defense_ai/ui/theme/app_theme.dart';

// Screens
import 'package:defense_ai/ui/screens/splash_screen.dart';
import 'package:defense_ai/ui/screens/home_screen.dart';
import 'package:defense_ai/ui/screens/golpes_br_screen.dart';
import 'package:defense_ai/ui/screens/tempo_real_screen.dart';
import 'package:defense_ai/ui/screens/vpn_segura_screen.dart';
import 'package:defense_ai/ui/screens/ajuda_screen.dart';
import 'package:defense_ai/ui/screens/premium_screen.dart';
import 'package:defense_ai/ui/screens/mais_protecoes_screen.dart';
import 'package:defense_ai/ui/screens/settings_screen.dart';
import 'package:defense_ai/ui/screens/qr_scanner_screen.dart';
import 'package:defense_ai/ui/screens/wifi_check_screen.dart';

// Sessão/assinatura
import 'package:defense_ai/core/session.dart';
// Consentimento (carregado no boot)
import 'package:defense_ai/services/consent_service.dart';
// Observer de navegação (analytics)
import 'package:defense_ai/core/nav_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  // ========= Handlers globais de erro (evitam crash no boot) =========
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details); // loga no console
    // Em produção: enviar para Crashlytics / Sentry
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    // ignore: avoid_print
    print('[FATAL] Uncaught: $error\n$stack');
    return true; // nós tratamos, não derruba o app
  };
  // ===================================================================

  // 1) Inicializa sessão ANTES de qualquer SDK (carrega Premium, etc.)
  await Session.init();

  // 2) Carrega consentimento salvo (sem UI). A UI será mostrada na Splash/Home.
  await ConsentService.load();

  // 3) NÃO inicializamos AdMob aqui; isso acontece na Splash/Home
  runApp(const MyApp());
}

class AppRoutes {
  static const splash = '/';
  static const home = '/home';
  static const golpesBR = '/golpes-br';
  static const tempoReal = '/tempo-real';
  static const vpnSegura = '/vpn-segura';
  static const ajuda = '/ajuda';
  static const premium = '/premium';
  static const maisProtecoes = '/mais-protecoes';
  static const settings = '/settings';
  static const qrScanner = '/qr-scanner';
  static const wifiCheck = '/wifi-check';
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? '';
    const premiumRoutes = {AppRoutes.tempoReal, AppRoutes.vpnSegura};

    final builders = <String, WidgetBuilder>{
      AppRoutes.splash:        (_) => const SplashScreen(),
      AppRoutes.home:          (_) => const HomeScreen(),
      AppRoutes.golpesBR:      (_) => const GolpesBRScreen(),
      AppRoutes.tempoReal:     (_) => const TempoRealScreen(),
      AppRoutes.vpnSegura:     (_) => const VpnSeguraScreen(),
      AppRoutes.ajuda:         (_) => const AjudaScreen(),
      AppRoutes.premium:       (_) => const PremiumScreen(),
      AppRoutes.maisProtecoes: (_) => const MaisProtecoesScreen(),
      AppRoutes.settings:      (_) => const SettingsScreen(),
      AppRoutes.qrScanner:     (_) => const QrScannerScreen(),
      AppRoutes.wifiCheck:     (_) => const WifiCheckScreen(),
    };

    // Guard premium global
    if (premiumRoutes.contains(name) && !Session.isPremium) {
      return MaterialPageRoute(
        builder: (_) => const PremiumScreen(),
        settings: const RouteSettings(name: AppRoutes.premium),
      );
    }

    final builder = builders[name];
    if (builder != null) {
      return MaterialPageRoute(builder: builder, settings: settings);
    }
    // Rota desconhecida → Home
    return MaterialPageRoute(
      builder: (_) => const HomeScreen(),
      settings: const RouteSettings(name: AppRoutes.home),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Defense.AI',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: _onGenerateRoute,
      navigatorObservers: [appNavObserver],
      onUnknownRoute: (_) => MaterialPageRoute(
        builder: (_) => const HomeScreen(),
        settings: const RouteSettings(name: AppRoutes.home),
      ),
    );
  }
}

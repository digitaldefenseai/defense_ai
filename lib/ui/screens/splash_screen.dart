// lib/ui/screens/splash_screen.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';

import 'package:defense_ai/main.dart';                  // AppRoutes
import 'package:defense_ai/ui/theme/brand_assets.dart'; // Brand

// Sessão (para checar se é Premium e pular inicialização de ads)
import 'package:defense_ai/core/session.dart';

// ⬅️ NOVO: sync de horário do servidor (persiste drift na Session)
import 'package:defense_ai/core/server_time.dart';

// Ads: inicialização e pré-carregamento só após consentimento
import 'package:defense_ai/services/ad_service.dart';
import 'package:defense_ai/services/ad_manager.dart';

// Consentimento leve (fallback UMP)
import 'package:defense_ai/services/consent_service.dart';

// ATT (iOS 14.5+)
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  String? _initialDeepLinkPath() {
    // Web: Uri.base.path traz a rota atual
    final p = Uri.base.path;
    if (p.isNotEmpty && p != '/' && p.startsWith('/')) return p;
    return null;
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _scale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    _ctrl.forward();

    // Executa boot assim que houver contexto válido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _initialDeepLinkPath() ?? AppRoutes.home;
      _bootAndGo(target);
    });
  }

  Future<void> _bootAndGo(String targetRoute) async {
    try {
      // Rodamos em paralelo para não travar o splash:
      await Future.wait([
        // 1) Consentimento (fallback leve) — só mostra 1x
        ConsentService.ensureConsentUI(context),

        // 2) Sincroniza horário do servidor e persiste drift (graceful em caso de erro)
        syncServerTime(),

        // 3) ATT no iOS (recomendado antes de ads personalizados)
        _maybeRequestATT(),

        // 4) Damos um pequeno delay estético
        Future.delayed(const Duration(milliseconds: 350)),
      ]);

      // 5) Inicializa AdMob somente se não for Web e não for Premium
      if (!kIsWeb && !Session.isPremium) {
        await AdService.initialize();
        AdManager.loadInterstitial();
        AdManager.loadRewarded();
      }
    } catch (e) {
      debugPrint('[Splash] boot error: $e');
    } finally {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, targetRoute);
    }
  }

  Future<void> _maybeRequestATT() async {
    if (kIsWeb) return;
    if (!Platform.isIOS) return;
    try {
      final status =
      await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    } catch (e) {
      debugPrint('[Splash] ATT error: $e');
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final asset = Brand.iconByTheme(context);

    final size = MediaQuery.of(context).size;
    final splashSize = (size.shortestSide * 0.30).clamp(200.0, 340.0);

    return Scaffold(
      backgroundColor: cs.background,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Image.asset(
              asset,
              height: splashSize,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              isAntiAlias: true,
            ),
          ),
        ),
      ),
    );
  }
}

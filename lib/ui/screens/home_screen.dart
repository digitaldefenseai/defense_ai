// lib/ui/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:defense_ai/main.dart'; // AppRoutes
import 'package:defense_ai/ui/theme/responsive.dart';
import 'package:defense_ai/ui/theme/brand_assets.dart';
import 'package:defense_ai/ui/theme/app_theme.dart';
import 'package:defense_ai/ui/widgets/ad_banner.dart';
import 'package:defense_ai/core/session.dart';

// Consentimento + Ads
import 'package:defense_ai/services/consent_service.dart';
import 'package:defense_ai/services/ad_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _adsInitialized = false;

  @override
  void initState() {
    super.initState();
    // Executa após o primeiro frame para podermos abrir UI de consentimento com contexto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAdsOnce(context);
    });
  }

  Future<void> _initAdsOnce(BuildContext context) async {
    if (_adsInitialized) return;
    if (Session.isPremium) { // Premium não vê ads
      _adsInitialized = true;
      return;
    }

    // 1) Versão leve: carrega decisão salva e pergunta 1x se ainda não perguntamos
    await ConsentService.load();
    await ConsentService.ensureConsentUI(context);

    // 2) Inicializa AdMob e pré-carrega formatos (respeitando consentimento via AdService)
    await AdService.initialize();
    AdService.loadInterstitialAd();
    AdService.loadRewardedAd();

    _adsInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    final double logoHeight = (size.width * 0.95).clamp(0, 380).toDouble();
    const EdgeInsets contentPadding = EdgeInsets.fromLTRB(12, 0, 12, 10);

    return Scaffold(
      appBar: null,

      // Banner fixo fora do scroll
      bottomNavigationBar: const SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(height: 1),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: AdBanner(),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: BR.contentMaxWidth),
            child: SingleChildScrollView(
              padding: contentPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 0, bottom: 2),
                    child: Text(
                      'SEU ESCUDO DIGITAL CONTRA GOLPES',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .2,
                      ),
                    ),
                  ),

                  // Logo
                  Center(
                    child: Semantics(
                      label: 'Logo Defense.AI',
                      image: true,
                      child: Image.asset(
                        Brand.logoFullByTheme(context),
                        height: logoHeight,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        isAntiAlias: true,
                        errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 64),
                      ),
                    ),
                  ),

                  const SizedBox(height: 2),

                  // ✅ Selo que se atualiza sozinho (escuta Session.premiumVersion lá dentro)
                  const _ProtectionBadge(),

                  const SizedBox(height: 4),

                  // Grid de features
                  LayoutBuilder(
                    builder: (context, constraints) {
                      int cross = 2;
                      if (constraints.maxWidth >= 600) cross = 3;
                      if (constraints.maxWidth >= 900) cross = 4;

                      final tiles = <_FeatureCard>[
                        const _FeatureCard(
                          index: 0,
                          icon: Icons.security,
                          tone: FeatureTone.free,
                          title: 'Scan Inteligente',
                          subtitle: 'Detecta ameaças e links suspeitos',
                          routeName: AppRoutes.qrScanner,
                        ),
                        const _FeatureCard(
                          index: 1,
                          icon: Icons.wifi_protected_setup,
                          tone: FeatureTone.free,
                          title: 'Proteção Wi-Fi',
                          subtitle: 'Verifica redes comprometidas',
                          routeName: AppRoutes.wifiCheck,
                        ),
                        const _FeatureCard(
                          index: 2,
                          icon: Icons.warning_amber,
                          tone: FeatureTone.free,
                          title: 'Golpes Brasil',
                          subtitle: 'Fraudes ativas na sua região',
                          routeName: AppRoutes.golpesBR,
                        ),
                        const _FeatureCard(
                          index: 3,
                          icon: Icons.shield,
                          tone: FeatureTone.premium,
                          title: 'Proteção Ativa',
                          subtitle: 'Alertas instantâneos de risco',
                          routeName: AppRoutes.tempoReal,
                        ),
                        const _FeatureCard(
                          index: 4,
                          icon: Icons.vpn_key,
                          tone: FeatureTone.premium,
                          title: 'VPN Segura',
                          subtitle: 'Navegação privada e protegida',
                          routeName: AppRoutes.vpnSegura,
                        ),
                        const _FeatureCard(
                          index: 5,
                          icon: Icons.emergency,
                          tone: FeatureTone.emergency,
                          title: 'Escudo de Emergência',
                          subtitle: 'Proteção instantânea de emergência',
                          routeName: AppRoutes.ajuda,
                        ),
                        const _FeatureCard(
                          index: 6,
                          icon: Icons.fingerprint,
                          tone: FeatureTone.safe,
                          title: 'Mais Proteções',
                          subtitle: 'Monitora CPF, PIX e dark web',
                          routeName: AppRoutes.maisProtecoes,
                        ),
                        const _FeatureCard(
                          index: 7,
                          icon: Icons.settings,
                          tone: FeatureTone.free,
                          title: 'Configurações',
                          subtitle: 'Conta e preferências',
                          routeName: AppRoutes.settings,
                        ),
                      ];

                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: cross,
                        crossAxisSpacing: BR.gridCrossAxisSpacing(context),
                        mainAxisSpacing: BR.gridMainAxisSpacing(context),
                        children: tiles,
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  // CTA Premium
                  Tooltip(
                    message: 'Conheça os recursos Premium',
                    waitDuration: const Duration(milliseconds: 400),
                    child: Semantics(
                      button: true,
                      label: 'Torne-se Premium',
                      hint: 'Abre a página de assinatura',
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.premium),
                        icon: const Icon(Icons.star),
                        label: const Text('Torne-se Premium', style: TextStyle(fontSize: 18)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: cs.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Versão
                  Center(
                    child: Text(
                      'V. A1-A2.0429',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* =========================
   Selo dinâmico (Básico/Premium...)
   ========================= */
class _ProtectionBadge extends StatelessWidget {
  const _ProtectionBadge();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: Session.premiumVersion,
      builder: (context, _, __) {
        final isPremium = Session.isPremium;
        final label = Session.badgeText();
        final color =
        isPremium ? AppTheme.getPremiumColor(context) : AppTheme.getSuccessColor(context);

        return Center(
          child: Semantics(
            container: true,
            label: 'Status da proteção: $label',
            child: GestureDetector(
              onLongPress: () async {
                await Session.clearPremium();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Premium limpo (apenas teste).')),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user, color: color, size: 18),
                    const SizedBox(width: 8),
                    Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// --- Feature cards (inalterados) ---
enum FeatureTone { free, premium, emergency, safe }
class _FeatureCard extends StatefulWidget {
  final int index;
  final IconData icon;
  final FeatureTone tone;
  final String title;
  final String subtitle;
  final String routeName;
  const _FeatureCard({
    required this.index,
    required this.icon,
    required this.tone,
    required this.title,
    required this.subtitle,
    required this.routeName,
    super.key,
  });
  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}
class _FeatureCardState extends State<_FeatureCard> with TickerProviderStateMixin {
  late final AnimationController _appearCtrl;
  late final Animation<double> _opacity;
  late final Animation<double> _slide;
  AnimationController? _pulseCtrl;
  bool _pressed = false;

  Color _toneColor(BuildContext context, ColorScheme cs) {
    switch (widget.tone) {
      case FeatureTone.premium:
        return AppTheme.getPremiumColor(context);
      case FeatureTone.emergency:
        return AppTheme.getEmergencyColor(context);
      case FeatureTone.safe:
        return AppTheme.getSuccessColor(context);
      case FeatureTone.free:
      default:
        return cs.primary;
    }
  }
  bool get _needsPulse => widget.tone == FeatureTone.premium || widget.tone == FeatureTone.emergency;

  @override
  void initState() {
    super.initState();
    final delayMs = 60 * widget.index;
    _appearCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _opacity = CurvedAnimation(parent: _appearCtrl, curve: Curves.easeOutCubic);
    _slide = Tween<double>(begin: 14, end: 0).animate(
      CurvedAnimation(parent: _appearCtrl, curve: Curves.easeOutCubic),
    );
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (mounted) _appearCtrl.forward();
    });
    if (_needsPulse) {
      _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100),
        lowerBound: 0.0, upperBound: 1.0,
      )..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _appearCtrl.dispose();
    _pulseCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final iconColor = _toneColor(context, cs);
    final scale = MediaQuery.textScaleFactorOf(context);
    final baseMin = BR.isSmall(context) ? 128.0 : (BR.isMedium(context) ? 140.0 : 156.0);
    final minHeight = scale > 1.2 ? baseMin * scale.clamp(1.0, 1.6) : baseMin;
    final pulse = _pulseCtrl == null
        ? 1.0
        : Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseCtrl!, curve: Curves.easeInOut),
    );

    return FadeTransition(
      opacity: _opacity,
      child: AnimatedBuilder(
        animation: _slide,
        builder: (context, child) => Transform.translate(offset: Offset(0, _slide.value), child: child),
        child: Semantics(
          button: true,
          label: widget.title,
          hint: widget.subtitle,
          child: Tooltip(
            message: '${widget.title}\n${widget.subtitle}',
            waitDuration: const Duration(milliseconds: 400),
            child: Card(
              elevation: 1.5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onHighlightChanged: (v) => setState(() => _pressed = v),
                onTap: () => Navigator.pushNamed(context, widget.routeName),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: baseMin),
                  child: Padding(
                    padding: BR.cardPadding(context),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedScale(
                          scale: (_pressed ? 0.92 : 1.0) * (pulse is Animation<double> ? pulse.value : 1.0),
                          duration: const Duration(milliseconds: 120),
                          curve: Curves.easeOut,
                          child: Icon(widget.icon, size: BR.cardIconSize(context), color: iconColor),
                        ),
                        BR.spacerS(context),
                        Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withOpacity(0.65),
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

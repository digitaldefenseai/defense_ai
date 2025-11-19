import 'package:flutter/material.dart';
import 'package:defense_ai/ui/widgets/content_shell.dart';
import 'package:defense_ai/ui/theme/responsive.dart';
import 'package:defense_ai/ui/theme/app_theme.dart';

// Session & Ads
import 'package:defense_ai/core/session.dart';
import 'package:defense_ai/services/ad_service.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  Future<void> _ativarAnual(BuildContext context) async {
    await Session.activateAnnual();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Premium Anual ativado.')),
    );
    Navigator.pop(context, true);
  }

  Future<void> _ativarSemestral(BuildContext context) async {
    await Session.activateSemiannual();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Premium Semestral ativado.')),
    );
    Navigator.pop(context, true);
  }

  Future<void> _ativarMensal(BuildContext context) async {
    await Session.activateMonthly();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Premium Mensal ativado.')),
    );
    Navigator.pop(context, true);
  }

  Future<void> _ativar24hViaRewarded(BuildContext context) async {
    if (!AdService.isRewardedReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Carregando anúncio... toque novamente em instantes.')),
      );
      AdService.loadRewardedAd();
      return;
    }

    AdService.showRewardedAd(onRewarded: () async {
      await Session.activateTempPremium(const Duration(hours: 24));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Premium ativado por 24h!')),
      );
      AdService.loadRewardedAd();
      Navigator.pop(context, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final premium = AppTheme.getPremiumColor(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seja Premium'),
        centerTitle: true,
      ),
      body: ContentShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Desbloqueie proteção total',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
            BR.spacerXS(context),
            Text(
              'Mais segurança, alertas em tempo real e VPN segura.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            BR.spacerM(context),

            // Tabela de recursos
            Card(
              color: cs.surfaceVariant,
              elevation: 0.5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: EdgeInsets.only(bottom: BR.spaceM(context)),
              child: Padding(
                padding: BR.cardPadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _row(theme, cs, 'Recurso', 'Free', 'Mensal', 'Anual', header: true),
                    const Divider(height: 24),
                    _row(theme, cs, 'Scan Inteligente', '✓', '✓', '✓'),
                    _row(theme, cs, 'Proteção Wi-Fi', '✓', '✓', '✓'),
                    _row(theme, cs, 'Proteção Ativa (Tempo Real)', '', '✓', '✓'),
                    _row(theme, cs, 'VPN Segura', '', '✓', '✓'),
                  ],
                ),
              ),
            ),

            // Planos
            _planButton(
              context,
              label: 'R\$ 99,90 / ano  •  Melhor custo-benefício',
              background: premium,
              foreground: Colors.white,
              semanticsLabel: 'Assinar plano anual por 99 reais e 90 centavos',
              tooltip: 'Assinatura anual',
              onPressed: () => _ativarAnual(context),
            ),
            BR.spacerS(context),

            _outlinedPlanButton(
              context,
              label: 'R\$ 79,90 / semestre',
              borderColor: premium,
              textColor: premium,
              semanticsLabel: 'Assinar plano semestral por 79 reais e 90 centavos',
              tooltip: 'Assinatura semestral',
              onPressed: () => _ativarSemestral(context),
            ),
            BR.spacerS(context),

            _outlinedPlanButton(
              context,
              label: 'R\$ 19,90 / mês',
              borderColor: cs.primary,
              textColor: cs.primary,
              semanticsLabel: 'Assinar plano mensal por 19 reais e 90 centavos',
              tooltip: 'Assinatura mensal',
              onPressed: () => _ativarMensal(context),
            ),

            BR.spacerM(context),

            // Alternativa gratuita temporária
            Semantics(
              button: true,
              label: 'Assistir anúncio para ativar recursos por 24 horas',
              child: Tooltip(
                message: 'Assistir anúncio (ativa por 24h)',
                waitDuration: const Duration(milliseconds: 400),
                child: TextButton(
                  onPressed: () => _ativar24hViaRewarded(context),
                  child: Text('Assistir anúncio (ativa por 24h)', style: TextStyle(color: cs.onSurfaceVariant)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Botões & Tabela

  Widget _planButton(
      BuildContext context, {
        required String label,
        required Color background,
        required Color foreground,
        required VoidCallback onPressed,
        required String semanticsLabel,
        required String tooltip,
      }) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Tooltip(
        message: tooltip,
        waitDuration: const Duration(milliseconds: 400),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: background,
            foregroundColor: foreground,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          // 🔧 Corrigido: usa o parâmetro label (o seu estava fixo/const)
          child: Text(label, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  Widget _outlinedPlanButton(
      BuildContext context, {
        required String label,
        required Color borderColor,
        required Color textColor,
        required VoidCallback onPressed,
        required String semanticsLabel,
        required String tooltip,
      }) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Tooltip(
        message: tooltip,
        waitDuration: const Duration(milliseconds: 400),
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            side: BorderSide(color: borderColor, width: 1.4),
            foregroundColor: textColor,
          ),
          child: Text(label, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor)),
        ),
      ),
    );
  }

  Widget _row(
      ThemeData theme,
      ColorScheme cs,
      String feature,
      String free,
      String mensal,
      String anual, {
        bool header = false,
      }) {
    final style = header
        ? theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800, color: cs.onSurface)
        : theme.textTheme.bodyMedium?.copyWith(color: cs.onSurface);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(feature, style: style)),
          Expanded(flex: 1, child: Center(child: Text(free, style: style))),
          Expanded(flex: 1, child: Center(child: Text(mensal, style: style))),
          Expanded(flex: 1, child: Center(child: Text(anual, style: style))),
        ],
      ),
    );
  }
}

// lib/ui/screens/mais_protecoes_screen.dart
import 'package:flutter/material.dart';
import 'package:defense_ai/ui/widgets/content_shell.dart';
import 'package:defense_ai/ui/theme/responsive.dart';
import 'package:defense_ai/ui/theme/app_theme.dart';

class MaisProtecoesScreen extends StatelessWidget {
  const MaisProtecoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mais Proteções'),
        centerTitle: true,
      ),
      body: ContentShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabeçalho curto (opcional)
            Text(
              'Catálogo de proteções',
              style: theme.textTheme.titleLarge?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            BR.spacerXS(context),
            Text(
              'Expanda sua segurança com ferramentas adicionais.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            BR.spacerM(context),

            // Opções
            _option(
              context,
              icon: Icons.account_balance_wallet,
              title: 'Proteção Financeira',
              subtitle: 'Pix/bancos',
              onTap: () {/* TODO */},
              premium: true,
            ),
            _option(
              context,
              icon: Icons.fingerprint,
              title: 'Monitoramento de Identidade',
              subtitle: 'CPF, cartão, dark web',
              onTap: () {/* TODO */},
              premium: true,
            ),
            _option(
              context,
              icon: Icons.family_restroom,
              title: 'Proteção Familiar',
              subtitle: 'Idosos/filhos',
              onTap: () {/* TODO */},
            ),
            _option(
              context,
              icon: Icons.devices,
              title: 'Controle de dispositivos',
              subtitle: 'Multi-device',
              onTap: () {/* TODO */},
            ),
            _option(
              context,
              icon: Icons.assessment,
              title: 'Relatórios semanais',
              subtitle: 'Detalhado',
              onTap: () {/* TODO */},
              premium: true,
            ),
            _option(
              context,
              icon: Icons.star_border,
              title: 'Gamificação',
              subtitle: 'Nível de segurança',
              onTap: () {/* TODO */},
            ),
          ],
        ),
      ),
    );
  }

  Widget _option(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
        bool premium = false,
      }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final premiumColor = AppTheme.getPremiumColor(context);

    return Card(
      color: cs.surfaceVariant,
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.only(bottom: BR.spaceS(context)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: BR.cardPadding(context),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: BR.isSmall(context) ? 26 : 30, color: cs.primary),
              SizedBox(width: BR.spaceM(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título + (opcional) tag Premium
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (premium) ...[
                          SizedBox(width: BR.spaceS(context)),
                          _premiumTag(context, premiumColor),
                        ],
                      ],
                    ),
                    BR.spacerXS(context),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: BR.spaceS(context)),
              Icon(Icons.arrow_forward_ios, size: 18, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _premiumTag(BuildContext context, Color premiumColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: premiumColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: premiumColor.withOpacity(0.45)),
      ),
      child: Text(
        'Premium',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: premiumColor,
          fontWeight: FontWeight.w800,
          letterSpacing: .2,
        ),
      ),
    );
  }
}

// lib/ui/screens/tempo_real_screen.dart
import 'package:flutter/material.dart';
import 'package:defense_ai/ui/widgets/content_shell.dart';
import 'package:defense_ai/ui/theme/responsive.dart';
import 'package:defense_ai/ui/theme/app_theme.dart';
import 'package:defense_ai/main.dart'; // AppRoutes

class TempoRealScreen extends StatefulWidget {
  const TempoRealScreen({super.key});

  @override
  State<TempoRealScreen> createState() => _TempoRealScreenState();
}

class _TempoRealScreenState extends State<TempoRealScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final premium = AppTheme.getPremiumColor(context);

    final iconSize = BR.isSmall(context) ? 84.0 : 100.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proteção Ativa'),
        centerTitle: true,
      ),
      body: ContentShell(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Chip "Recurso Premium"
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: premium.withOpacity(0.14),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: premium.withOpacity(0.35)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 16, color: premium),
                  const SizedBox(width: 6),
                  Text(
                    'Recurso Premium',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: premium,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            BR.spacerL(context),

            // Ícone com micro-animação (pulse)
            ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.06)
                  .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut)),
              child: Icon(Icons.shield, size: iconSize, color: premium),
            ),

            BR.spacerM(context),

            // Mensagem
            Padding(
              padding: EdgeInsets.symmetric(horizontal: BR.isSmall(context) ? 12 : 24),
              child: Text(
                'Proteção ativa contra ameaças em tempo real.\n'
                    'Receba alertas instantâneos e bloqueios preventivos.',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(color: cs.onSurface),
              ),
            ),

            BR.spacerL(context),

            // CTA principal
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.premium),
              icon: const Icon(Icons.star),
              label: const Text('Torne-se Premium', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            BR.spacerS(context),

            // CTA secundária (opcional)
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.premium),
              child: const Text('Saiba mais sobre os benefícios'),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/ui/screens/vpn_segura_screen.dart
import 'package:flutter/material.dart';
import 'package:defense_ai/ui/widgets/content_shell.dart';
import 'package:defense_ai/ui/theme/responsive.dart';
import 'package:defense_ai/ui/theme/app_theme.dart';

class VpnSeguraScreen extends StatefulWidget {
  const VpnSeguraScreen({super.key});

  @override
  State<VpnSeguraScreen> createState() => _VpnSeguraScreenState();
}

class _VpnSeguraScreenState extends State<VpnSeguraScreen>
    with SingleTickerProviderStateMixin {
  bool _connected = false;

  late final AnimationController _pulse =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _toggleVpn() {
    setState(() {
      _connected = !_connected;
      if (_connected) {
        _pulse.repeat(reverse: true);
      } else {
        _pulse.stop();
        _pulse.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final premium = AppTheme.getPremiumColor(context);
    final success = AppTheme.getSuccessColor(context);
    final emergency = AppTheme.getEmergencyColor(context);

    final iconSize = BR.isSmall(context) ? 84.0 : 100.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('VPN Segura'),
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

            // Ícone com micro-animação (pulse quando conectado)
            ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.06).animate(
                CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
              ),
              child: Icon(
                Icons.vpn_key,
                size: iconSize,
                color: _connected ? success : cs.primary,
              ),
            ),

            BR.spacerS(context),

            // Estado atual em “pill”
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (_connected ? success : cs.outline).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: (_connected ? success : cs.outline).withOpacity(0.35),
                ),
              ),
              child: Text(
                _connected ? 'Conectada • Tráfego protegido' : 'Desconectada',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: _connected ? success : cs.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            BR.spacerL(context),

            // Botão principal: Conectar / Desconectar
            ElevatedButton(
              onPressed: _toggleVpn,
              style: ElevatedButton.styleFrom(
                backgroundColor: _connected ? emergency : cs.primary,
                foregroundColor: cs.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(_connected ? 'Desconectar' : 'Conectar VPN',
                  style: const TextStyle(fontSize: 18)),
            ),

            BR.spacerM(context),

            // Informações de uso (mock)
            Text(
              _connected ? 'Tráfego protegido' : 'Pronta para conectar',
              style: theme.textTheme.titleMedium?.copyWith(color: cs.onSurface),
            ),
            Text(
              _connected ? '10,2 MB de 500 MB' : 'Plano básico: 500 MB',
              style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
            ),

            BR.spacerM(context),

            // CTA secundária
            TextButton(
              onPressed: () {
                // TODO: enviar para tela de planos/premium
              },
              child: const Text('Desbloquear mais +'),
            ),
          ],
        ),
      ),
    );
  }
}

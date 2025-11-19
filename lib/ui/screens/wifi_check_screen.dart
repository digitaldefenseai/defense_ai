// lib/ui/screens/wifi_check_screen.dart
import 'package:flutter/material.dart';
import 'package:defense_ai/ui/widgets/content_shell.dart';
import 'package:defense_ai/ui/theme/responsive.dart';
import 'package:defense_ai/ui/theme/app_theme.dart';
import 'package:defense_ai/services/security_service.dart';

class WifiCheckScreen extends StatefulWidget {
  const WifiCheckScreen({super.key});

  @override
  State<WifiCheckScreen> createState() => _WifiCheckScreenState();
}

class _WifiCheckScreenState extends State<WifiCheckScreen> {
  final _ssidController = TextEditingController();
  bool _loading = false;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _ssidController.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final ssid = _ssidController.text.trim();
    if (ssid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o nome (SSID) da rede Wi-Fi.')),
      );
      return;
    }

    setState(() {
      _loading = true;
      _result = null;
    });

    try {
      final res = await SecurityService().analyzeWiFi(ssid);
      if (!mounted) return;
      setState(() => _result = res);

      final isSuspicious = res['isSuspicious'] == true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isSuspicious
                ? '⚠️ Rede potencialmente arriscada'
                : '✅ Nenhum sinal forte de risco',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proteção Wi-Fi'),
        centerTitle: true,
      ),
      body: ContentShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ícone + microdescrição
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wifi_protected_setup,
                  size: BR.isSmall(context) ? 72 : 88,
                  color: cs.primary,
                ),
                BR.spacerS(context),
                Text(
                  'Verifique se a rede é confiável',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            BR.spacerM(context),

            // Campo SSID
            TextField(
              controller: _ssidController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: 'Digite o nome da rede (SSID), ex.: Free Wi-Fi',
                filled: true,
                fillColor: cs.surfaceVariant.withOpacity(.35),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => _analyze(),
            ),

            BR.spacerS(context),

            // Ação principal
            ElevatedButton.icon(
              onPressed: _loading ? null : _analyze,
              icon: _loading
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.shield),
              label: Text(_loading ? 'Analisando...' : 'Verificar agora'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            BR.spacerM(context),

            // Resultado da análise
            if (_result != null) _ResultCard(result: _result!),

            BR.spacerM(context),

            // O que verificamos
            Card(
              color: cs.surfaceVariant.withOpacity(0.55),
              elevation: 0.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: BR.cardPadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 20, color: cs.onSurface),
                        const SizedBox(width: 8),
                        Text(
                          'O que verificamos',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                    BR.spacerS(context),
                    _tipItem(context, 'Criptografia do Wi-Fi (WPA2/WPA3 vs. WEP/aberto).'),
                    _tipItem(context, 'Suspeita de DNS hijacking / captive portal malicioso.'),
                    _tipItem(context, 'Rede aberta / hotspot falso / MITM provável.'),
                    _tipItem(context, 'Roteador com senha fraca ou padrão.'),
                    _tipItem(context, 'Serviços/portas locais potencialmente expostos.'),
                  ],
                ),
              ),
            ),

            BR.spacerS(context),

            // Recomendações rápidas
            Card(
              color: cs.surfaceVariant.withOpacity(0.35),
              elevation: 0.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: BR.cardPadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, size: 20, color: cs.onSurface),
                        const SizedBox(width: 8),
                        Text(
                          'Recomendações rápidas',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                    BR.spacerS(context),
                    _tipItem(context, 'Use WPA3 (ou WPA2-AES) e desative WPS.'),
                    _tipItem(context, 'Troque a senha do roteador e atualize o firmware.'),
                    _tipItem(context, 'Evite redes públicas para operações sensíveis.'),
                    _tipItem(context, 'Considere usar a VPN segura do Defense.AI.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tipItem(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 18, color: cs.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});
  final Map<String, dynamic> result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final name = (result['networkName'] ?? '').toString();
    final isSuspicious = result['isSuspicious'] == true;
    final isSecure = result['isSecure'] == true;
    final risk = (result['riskLevel'] ?? 'low').toString();
    final rec = (result['recommendation'] ?? '').toString();

    Color badge;
    switch (risk) {
      case 'high':
        badge = AppTheme.getEmergencyColor(context);
        break;
      case 'medium':
        badge = AppTheme.getPremiumColor(context);
        break;
      default:
        badge = AppTheme.getSuccessColor(context);
    }

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cs.surfaceVariant.withOpacity(.35),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header
            Row(
              children: [
                Icon(
                  isSuspicious ? Icons.warning_amber : Icons.verified_user,
                  color: badge,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    name.isEmpty ? 'Rede analisada' : name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: badge.withOpacity(.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: badge.withOpacity(.35)),
                  ),
                  child: Text(
                    'Risco: ${risk.toUpperCase()}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: badge,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            _kv('Segura', isSecure ? 'Sim' : 'Não', context),
            const SizedBox(height: 4),
            Text(
              rec,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v, BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            k,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            v,
            style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurface),
          ),
        ),
      ],
    );
  }
}

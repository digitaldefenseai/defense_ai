// lib/ui/screens/qr_scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <- para colar da área de transferência
import 'package:defense_ai/ui/widgets/content_shell.dart';
import 'package:defense_ai/ui/theme/responsive.dart';
import 'package:defense_ai/ui/theme/app_theme.dart';
import 'package:defense_ai/services/security_service.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final _urlController = TextEditingController();
  bool _loading = false;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A área de transferência está vazia.')),
      );
      return;
    }
    if (!mounted) return;
    setState(() => _urlController.text = text);
  }

  Future<void> _analyzeUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cole ou digite uma URL para analisar.')),
      );
      return;
    }

    setState(() {
      _loading = true;
      _result = null;
    });

    try {
      final res = await SecurityService().analyzeUrl(url);
      if (!mounted) return;
      setState(() => _result = res);

      final isSuspicious = res['isSuspicious'] == true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isSuspicious ? '⚠️ URL suspeita detectada' : '✅ Sem sinais fortes de risco',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Inteligente'),
        centerTitle: true,
      ),
      body: ContentShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ícone + título + micro descrição
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  size: BR.isSmall(context) ? 72 : 88,
                  color: cs.primary,
                ),
                BR.spacerS(context),
                Text(
                  'Detecta ameaças e links suspeitos',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            BR.spacerM(context),

            // Campo para colar/digitar URL
            TextField(
              controller: _urlController,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: 'Cole aqui a URL (ex.: https://seubanco.com.br/...)',
                filled: true,
                fillColor: cs.surfaceVariant.withOpacity(.35),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  tooltip: 'Colar',
                  icon: const Icon(Icons.content_paste),
                  onPressed: _pasteFromClipboard,
                ),
              ),
              onSubmitted: (_) => _analyzeUrl(),
            ),

            BR.spacerS(context),

            // Ações principais
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _analyzeUrl,
                    icon: _loading
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.search), // <- ícone compatível
                    label: Text(_loading ? 'Analisando...' : 'Analisar URL'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Leitura de QR virá depois (câmera). Por ora, cole a URL.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Ler QR'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: cs.primary),
                    foregroundColor: cs.primary,
                  ),
                ),
              ],
            ),

            BR.spacerM(context),

            if (_result != null) _ResultCard(result: _result!),

            // Dicas/aviso em card
            BR.spacerM(context),
            Card(
              color: cs.surfaceVariant.withOpacity(0.55),
              elevation: 0.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.only(bottom: BR.spaceS(context)),
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
                          'Como funciona',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                    BR.spacerS(context),
                    _tipItem(context, 'Verifica se o QR/URL aponta para páginas suspeitas.'),
                    _tipItem(context, 'Checa encurtadores e redirecionamentos maliciosos.'),
                    _tipItem(context, 'Sinaliza phishing e spyware conhecidos.'),
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

    final url = (result['url'] ?? '').toString();
    final isSuspicious = result['isSuspicious'] == true;
    final isSecure = result['isSecure'] == true;
    final risk = (result['riskLevel'] ?? 'low').toString();
    final analysis = (result['analysis'] ?? '').toString();

    Color badgeColor;
    switch (risk) {
      case 'high':
        badgeColor = AppTheme.getEmergencyColor(context);
        break;
      case 'medium':
        badgeColor = AppTheme.getPremiumColor(context);
        break;
      default:
        badgeColor = AppTheme.getSuccessColor(context);
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
            // Header
            Row(
              children: [
                Icon(
                  isSuspicious ? Icons.warning_amber : Icons.verified_user,
                  color: badgeColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    url,
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
                    color: badgeColor.withOpacity(.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: badgeColor.withOpacity(.35)),
                  ),
                  child: Text(
                    'Risco: ${risk.toUpperCase()}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            _kv('HTTPS', isSecure ? 'Sim' : 'Não', context),
            const SizedBox(height: 4),
            Text(
              analysis,
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

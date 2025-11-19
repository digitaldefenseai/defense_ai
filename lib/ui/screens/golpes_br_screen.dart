// lib/ui/screens/golpes_br_screen.dart
import 'package:flutter/material.dart';

import 'package:defense_ai/ui/widgets/content_shell.dart';
import 'package:defense_ai/ui/theme/responsive.dart';
import 'package:defense_ai/ui/theme/app_theme.dart';

import 'package:defense_ai/services/security_service.dart';

class GolpesBRScreen extends StatefulWidget {
  const GolpesBRScreen({super.key});

  @override
  State<GolpesBRScreen> createState() => _GolpesBRScreenState();
}

class _GolpesBRScreenState extends State<GolpesBRScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite ou cole uma mensagem para analisar.')),
      );
      return;
    }

    setState(() {
      _loading = true;
      _result = null;
    });

    try {
      final res = SecurityService().analyzeText(text);
      setState(() => _result = res);

      final isScam = res['isScam'] == true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isScam
              ? '⚠️ Indícios de golpe detectados'
              : '✅ Sem sinais fortes de golpe'),
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
        title: const Text('Golpes BR'),
        centerTitle: true,
      ),
      body: ContentShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabeçalho
            Text(
              'Cole aqui uma mensagem suspeita (SMS, WhatsApp, e-mail)',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            BR.spacerS(context),

            // Campo de texto
            TextField(
              controller: _controller,
              maxLines: 6,
              minLines: 4,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText:
                'Ex.: “URGENTE! Seu PIX foi bloqueado. Clique para liberar...”',
                filled: true,
                fillColor: cs.surfaceVariant.withOpacity(.35),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            BR.spacerS(context),

            // Botão analisar
            ElevatedButton.icon(
              onPressed: _loading ? null : _analyze,
              icon: _loading
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.search),
              label: Text(_loading ? 'Analisando...' : 'Analisar mensagem'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            BR.spacerM(context),

            // Resultado da análise
            if (_result != null) _ResultCard(result: _result!),

            BR.spacerM(context),

            // Lista educativa de golpes comuns
            const _KnownScamsSection(),
          ],
        ),
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

    final isScam = result['isScam'] == true;
    final risk = (result['riskLevel'] ?? 'low').toString();
    final scamType = (result['scamType'] ?? '-').toString();
    final description = (result['description'] ?? '-').toString();
    final confidence = (result['confidence'] ?? 0).toString();

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
            // Header do resultado
            Row(
              children: [
                Icon(isScam ? Icons.warning_amber : Icons.verified, color: badgeColor),
                const SizedBox(width: 8),
                Text(
                  isScam ? 'Possível golpe detectado' : 'Sem sinais fortes de golpe',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                const Spacer(),
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

            // Detalhes
            _kv('Tipo', scamType, context),
            _kv('Descrição', description, context),
            _kv('Confiança', '$confidence%', context),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v, BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 110,
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
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface,
                height: 1.15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KnownScamsSection extends StatelessWidget {
  const _KnownScamsSection();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final scams = SecurityService().getKnownScams();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Golpes comuns no Brasil',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: scams
              .map((s) => Chip(
            label: Text(s['type']),
            backgroundColor: cs.surfaceVariant.withOpacity(.35),
          ))
              .toList(),
        ),
      ],
    );
  }
}

// lib/ui/screens/ajuda_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:defense_ai/ui/widgets/content_shell.dart';
import 'package:defense_ai/ui/theme/responsive.dart';
import 'package:defense_ai/ui/theme/app_theme.dart';
import 'package:defense_ai/services/security_service.dart';

class AjudaScreen extends StatefulWidget {
  const AjudaScreen({super.key});

  @override
  State<AjudaScreen> createState() => _AjudaScreenState();
}

class _AjudaScreenState extends State<AjudaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _msgCtrl = TextEditingController(
    text:
    'Estou em situação de risco/fraude. Preciso de ajuda urgente. Verifiquem meus acessos.',
  );
  final _contatoCtrl = TextEditingController(); // e-mail/telefone (opcional)
  bool _sending = false;

  @override
  void dispose() {
    _msgCtrl.dispose();
    _contatoCtrl.dispose();
    super.dispose();
  }

  void _preencherSOS() {
    _msgCtrl.text =
    'SOS! Possível golpe/roubo. Bloqueiem operações e avisem meus contatos.';
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mensagem SOS preenchida.')),
    );
  }

  Future<void> _enviarAlerta() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.heavyImpact();

    setState(() => _sending = true);
    try {
      final ok = await SecurityService()
          .sendEmergencyAlert(_msgCtrl.text.trim(), _contatoCtrl.text.trim());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok ? '✅ Alerta enviado com sucesso.' : '⚠️ Falha ao enviar o alerta.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      if (ok) {
        // Mantém a mensagem para reuso rápido; limpa o contato
        _contatoCtrl.clear();
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final danger = AppTheme.getEmergencyColor(context);

    // Altura mínima do botão grande, adaptada ao textScaleFactor
    final scale = MediaQuery.textScaleFactorOf(context);
    final baseMin = BR.isSmall(context) ? 56.0 : 60.0;
    final minHeight = scale > 1.2 ? baseMin * scale.clamp(1.0, 1.6) : baseMin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escudo de Emergência'),
        centerTitle: true,
      ),
      body: ContentShell(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ===== Cabeçalho =====
              Row(
                children: [
                  Icon(Icons.emergency, color: danger),
                  const SizedBox(width: 8),
                  Text(
                    'Ação rápida em caso de golpe',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),

              BR.spacerM(context),

              // ===== Mensagem =====
              TextFormField(
                controller: _msgCtrl,
                maxLines: 4,
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Descreva o que aconteceu.' : null,
                decoration: InputDecoration(
                  labelText: 'Mensagem de alerta',
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: cs.surfaceVariant.withOpacity(.35),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              BR.spacerS(context),

              // ===== Contato (opcional) =====
              TextFormField(
                controller: _contatoCtrl,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Contato para retorno (opcional: e-mail/telefone)',
                  filled: true,
                  fillColor: cs.surfaceVariant.withOpacity(.25),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: (_contatoCtrl.text.isNotEmpty)
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(_contatoCtrl.clear),
                    tooltip: 'Limpar',
                  )
                      : null,
                ),
                onChanged: (_) => setState(() {}),
              ),

              BR.spacerM(context),

              // ===== Ações principais =====
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _sending ? null : _enviarAlerta,
                      icon: _sending
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Icon(Icons.send),
                      label: Text(_sending ? 'Enviando...' : 'Enviar alerta agora'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _sending ? null : _preencherSOS,
                    icon: const Icon(Icons.flash_on),
                    label: const Text('SOS'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: danger),
                      foregroundColor: danger,
                    ),
                  ),
                ],
              ),

              BR.spacerL(context),

              // ===== Dicas =====
              Card(
                color: cs.surfaceVariant.withOpacity(0.45),
                elevation: 0.5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                            'Quando usar',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                        ],
                      ),
                      BR.spacerS(context),
                      _tip(context, 'Perda/roubo do aparelho.'),
                      _tip(context, 'Links suspeitos clicados recentemente.'),
                      _tip(context, 'Cobranças/transferências indevidas.'),
                    ],
                  ),
                ),
              ),

              BR.spacerM(context),

              // ===== Ações secundárias (placeholders) =====
              _helpOption(
                context,
                title: 'Configurar contato de confiança',
                tooltip: 'Defina quem será avisado em caso de emergência',
                onTap: () {
                  // TODO: fluxo de contato de confiança
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Em breve: contato de confiança.')),
                  );
                },
              ),
              _helpOption(
                context,
                title: 'Histórico de alertas',
                tooltip: 'Veja alertas enviados anteriormente',
                onTap: () {
                  // TODO: fluxo de histórico
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Em breve: histórico de alertas.')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _helpOption(
      BuildContext context, {
        required String title,
        required VoidCallback onTap,
        String? tooltip,
      }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Semantics(
      button: true,
      label: title,
      child: Tooltip(
        message: tooltip ?? title,
        waitDuration: const Duration(milliseconds: 400),
        child: Card(
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
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(color: cs.onSurface),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 18, color: cs.onSurfaceVariant),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tip(BuildContext context, String text) {
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

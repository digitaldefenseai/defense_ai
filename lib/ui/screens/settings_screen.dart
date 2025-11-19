// lib/ui/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:defense_ai/ui/widgets/content_shell.dart';
import 'package:defense_ai/ui/theme/responsive.dart';
import 'package:defense_ai/services/consent_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Preferências locais de UI (mock)
  bool _realTimeNotifications = true;
  bool _silentNotifications = false;
  String _alertLevel = 'Básico';
  String _language = 'Português';

  // TODO: 🔁 Troque pela sua URL real da Política de Privacidade
  static const String _kPrivacyUrl = 'https://example.com/privacy';

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    final ok = await canLaunchUrl(uri);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o link.')),
      );
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _reviewAdsConsent() async {
    await ConsentService.ensureConsentUI(context);
    if (!mounted) return;
    final personalized = ConsentService.isPersonalized;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          personalized
              ? 'Preferência salva: anúncios personalizados.'
              : 'Preferência salva: anúncios limitados.',
        ),
      ),
    );
    setState(() {}); // atualiza o subtítulo mostrado
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        centerTitle: true,
      ),
      body: ContentShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ===== Seção: Notificações =====
            _sectionCard(
              context,
              icon: Icons.notifications,
              title: 'Notificações',
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.bolt_outlined),
                    title: const Text('Tempo Real'),
                    subtitle: const Text('Receba alertas assim que detectarmos um risco'),
                    value: _realTimeNotifications,
                    onChanged: (v) => setState(() => _realTimeNotifications = v),
                  ),
                  const Divider(height: 20),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.notifications_off_outlined),
                    title: const Text('Silencioso'),
                    subtitle: const Text('Mantém notificações sem som/vibração'),
                    value: _silentNotifications,
                    onChanged: (v) => setState(() => _silentNotifications = v),
                  ),
                ],
              ),
            ),

            BR.spacerS(context),

            // ===== Seção: Nível de Alerta =====
            _sectionCard(
              context,
              icon: Icons.security,
              title: 'Nível de Alerta',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip('Básico', _alertLevel == 'Básico',
                          (sel) => setState(() => _alertLevel = 'Básico')),
                  _chip('Moderado', _alertLevel == 'Moderado',
                          (sel) => setState(() => _alertLevel = 'Moderado')),
                  _chip('Completo', _alertLevel == 'Completo',
                          (sel) => setState(() => _alertLevel = 'Completo')),
                ],
              ),
            ),

            BR.spacerS(context),

            // ===== Seção: Idioma =====
            _sectionCard(
              context,
              icon: Icons.language,
              title: 'Idioma',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip('Português', _language == 'Português',
                          (sel) => setState(() => _language = 'Português')),
                  _chip('Inglês', _language == 'Inglês',
                          (sel) => setState(() => _language = 'Inglês')),
                  _chip('Espanhol', _language == 'Espanhol',
                          (sel) => setState(() => _language = 'Espanhol')),
                ],
              ),
            ),

            BR.spacerS(context),

            // ===== Seção: Privacidade & Anúncios =====
            _sectionCard(
              context,
              icon: Icons.privacy_tip_outlined,
              title: 'Privacidade e Anúncios',
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.policy_outlined),
                    title: const Text('Política de Privacidade'),
                    subtitle: const Text('Abrir no navegador'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => _openUrl(_kPrivacyUrl),
                  ),
                  const Divider(height: 20),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.ad_units_outlined),
                    title: const Text('Preferência de anúncios'),
                    subtitle: Text(
                      ConsentService.isPersonalized
                          ? 'Personalizados (com base na atividade)'
                          : 'Limitados (não personalizados)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    trailing: const Icon(Icons.tune),
                    onTap: _reviewAdsConsent,
                  ),
                ],
              ),
            ),

            BR.spacerL(context),

            // Versão
            Center(
              child: Text(
                'Versão do App: A1-A2.0429',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== Helpers =====

  Widget _sectionCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required Widget child,
      }) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      color: cs.surfaceVariant.withOpacity(0.55),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: BR.cardPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionHeader(context, icon, title),
            BR.spacerS(context),
            child,
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, IconData icon, String title) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Row(
      children: [
        Icon(icon, size: 22, color: cs.onSurface),
        const SizedBox(width: 10),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _chip(String text, bool selected, Function(bool) onSelected) {
    final cs = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(text),
      selected: selected,
      onSelected: onSelected,
      selectedColor: cs.primary.withOpacity(0.20),
      labelStyle: TextStyle(color: selected ? cs.primary : cs.onSurface),
      side: BorderSide(color: selected ? cs.primary : cs.outlineVariant),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

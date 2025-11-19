import 'package:flutter/material.dart';

/// Ponto único de verdade para assets de marca.
/// Se trocar arquivos no futuro, ajuste só aqui.
class Brand {
  // ===== Caminhos atuais (mantidos como você já tem) =====
  // Logo completa (wordmark)
  static const _logoLightFull = 'assets/images/logo.png'; // tema claro
  static const _logoDarkFull  = 'assets/images/logo_defenseai_dark_full.png'; // tema escuro

  // Ícones (opcionais para uso dentro do app – não confundir com launcher icon)
  static const _iconLight = 'assets/images/logo_defenseai_light_icon.png';
  static const _iconDark  = 'assets/images/logo_defenseai_dark_icon.png'; // crie quando quiser

  // Se você AINDA NÃO tiver o arquivo _iconDark no projeto, mantenha false.
  // Quando adicionar o PNG dark, troque para true para usá-lo automaticamente.
  static const bool _hasDarkIcon = false;

  /// Logo completa conforme o tema (recomendada para a Home).
  static String logoFullByTheme(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? _logoDarkFull : _logoLightFull;
  }

  /// Ícone conforme o tema (para usos internos no app, NÃO é o launcher icon).
  /// Se o ícone dark ainda não existir, cai no fallback usando a logo dark completa.
  static String iconByTheme(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return _hasDarkIcon ? _iconDark : _logoDarkFull; // fallback seguro
    }
    return _iconLight;
  }

  // ===== Acessos diretos, caso precise em algum ponto específico =====
  static String get logoLightFull => _logoLightFull;
  static String get logoDarkFull  => _logoDarkFull;
  static String get iconLight     => _iconLight;
  static String get iconDark      => _iconDark;
}

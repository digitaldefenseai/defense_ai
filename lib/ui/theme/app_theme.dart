// lib/ui/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:defense_ai/ui/theme/defense_badge_theme.dart';

/// Tema centralizado do Defense.AI (Material 3)
/// - ColorScheme por seed
/// - Tipografia ajustada (títulos/labels com peso maior)
/// - Ícones/botões com estados harmonizados
/// - Ripple (InkRipple) e cores de interação consistentes
/// - Helpers de cor (success/safe/premium/emergency) para uso nas telas
class AppTheme {
  // Azul-base (troque quando oficializar a paleta)
  static const Color seed = Color(0xFF1565C0);

  /// ---- Helpers de Tipografia ----
  static TextTheme _textTheme(Brightness b, ColorScheme cs) {
    // Base Material 3
    final base = b == Brightness.dark
        ? Typography.material2021(platform: TargetPlatform.android).white
        : Typography.material2021(platform: TargetPlatform.android).black;

    // Ajustes de peso/legibilidade em itens que usamos muito
    final tuned = base.copyWith(
      titleLarge:  base.titleLarge ?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      titleSmall:  base.titleSmall ?.copyWith(fontWeight: FontWeight.w600),
      labelLarge:  base.labelLarge ?.copyWith(fontWeight: FontWeight.w600),
      labelMedium: base.labelMedium?.copyWith(fontWeight: FontWeight.w600),
      bodyMedium:  base.bodyMedium ?.copyWith(height: 1.25),
      bodySmall:   base.bodySmall  ?.copyWith(height: 1.25),
    ).apply(
      bodyColor: cs.onSurface,
      displayColor: cs.onSurface,
    );

    return tuned;
  }

  /// ---- IconButton coerente em hover/focus/pressed/disabled ----
  static IconButtonThemeData _iconButtonTheme(ColorScheme cs) {
    Color resolve(Set<MaterialState> s) {
      if (s.contains(MaterialState.disabled)) return cs.onSurface.withOpacity(0.38);
      if (s.contains(MaterialState.pressed))  return cs.primary;
      if (s.contains(MaterialState.hovered) || s.contains(MaterialState.focused)) {
        return cs.primary.withOpacity(0.90);
      }
      return cs.onSurface;
    }

    return IconButtonThemeData(
      style: ButtonStyle(
        iconColor:   MaterialStateProperty.resolveWith(resolve),
        overlayColor: MaterialStatePropertyAll(cs.primary.withOpacity(0.08)),
      ),
    );
  }

  /// ---- Base comum light/dark ----
  static ThemeData _base({
    required Brightness brightness,
    required Color scaffoldBg,
    required SystemUiOverlayStyle overlay,
    Color? cardColor,
  }) {
    final cs = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: scaffoldBg,

      // AppBar “flat” e legível + status bar correta
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        foregroundColor: cs.onSurface,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: overlay,
      ),

      // Card com cantos e elevação suaves
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.zero,
      ),

      // Botões elevados padronizados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),

      // Ícones usam paleta do esquema
      iconTheme: IconThemeData(color: cs.primary),
      iconButtonTheme: _iconButtonTheme(cs),

      // Cores de interação (ripple/hover/focus)
      splashFactory: InkRipple.splashFactory,
      splashColor: cs.primary.withOpacity(0.12),
      highlightColor: Colors.transparent,
      hoverColor: cs.primary.withOpacity(0.08),
      focusColor: cs.primary.withOpacity(0.12),

      // Divisores mais sutis
      dividerTheme: DividerThemeData(
        color: cs.outlineVariant.withOpacity(0.50),
        thickness: 1,
        space: 24,
      ),

      // ListTile com subtítulo mais legível
      listTileTheme: ListTileThemeData(
        iconColor: cs.primary,
        textColor: cs.onSurface,
        subtitleTextStyle: TextStyle(
          color: cs.onSurfaceVariant,
          height: 1.25,
        ),
      ),

      // Tipografia (aplicada ao fim para herdar esquema)
      textTheme: _textTheme(brightness, cs),

      // ThemeExtension para o badge (definido por tema)
      extensions: [
        if (brightness == Brightness.light)
          const DefenseBadgeTheme(
            fill:   Color(0xFFE6F6EE),
            border: Color(0xFF7AD7A1),
            text:   Color(0xFF0F5C36),
          )
        else
          const DefenseBadgeTheme(
            fill:   Color(0xFF103625),
            border: Color(0xFF2CBF72),
            text:   Color(0xFFB8F5D0),
          ),
      ],
    );
  }

  /// ===================== LIGHT =====================
  static ThemeData get light => _base(
    brightness: Brightness.light,
    scaffoldBg: ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    ).surface,
    overlay: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // Android
      statusBarBrightness: Brightness.light,    // iOS
    ),
  );

  /// ===================== DARK =====================
  static ThemeData get dark => _base(
    brightness: Brightness.dark,
    scaffoldBg: const Color(0xFF0A0F1C),
    overlay: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // Android
      statusBarBrightness: Brightness.dark,      // iOS
    ),
    cardColor: ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    ).surfaceVariant.withOpacity(0.22),
  );

  // ===================== HELPERS DE COR =====================
  /// Seguro/OK (ex.: chip “Seguro”, status em telas)
  static Color safe(BuildContext c) => Colors.green.shade500;

  /// Sucesso (equivalente semântico de “safe”, mantém os dois se quiser diferenciar)
  static Color success(BuildContext c) => Colors.green.shade600;

  /// Premium/Realce (ex.: ícones dourados, recursos premium)
  static Color premium(BuildContext c) => Colors.amber.shade600;

  /// Emergência/Alerta (ex.: botão pânico, risco alto)
  static Color emergency(BuildContext c) => Colors.red.shade500;

  /// Texto sutil sobre surface (para subtítulos, descrições)
  static Color subtleOnSurface(BuildContext c) =>
      Theme.of(c).colorScheme.onSurface.withOpacity(0.65);

  /// Borda/linha fraca coerente com o tema
  static Color borderMuted(BuildContext c) =>
      Theme.of(c).colorScheme.outlineVariant.withOpacity(0.35);

  // ---------- ALIASES (compatibilidade com nomes antigos) ----------
  static Color getSuccessColor(BuildContext ctx) => success(ctx);
  static Color getPremiumColor(BuildContext ctx) => premium(ctx);
  static Color getEmergencyColor(BuildContext ctx) => emergency(ctx);
}

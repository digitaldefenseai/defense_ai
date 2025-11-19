// lib/ui/theme/defense_badge_theme.dart
import 'package:flutter/material.dart';

/// ThemeExtension para padronizar as cores do "badge de nível"
@immutable
class DefenseBadgeTheme extends ThemeExtension<DefenseBadgeTheme> {
  final Color fill;
  final Color border;
  final Color text;

  const DefenseBadgeTheme({
    required this.fill,
    required this.border,
    required this.text,
  });

  @override
  DefenseBadgeTheme copyWith({Color? fill, Color? border, Color? text}) {
    return DefenseBadgeTheme(
      fill: fill ?? this.fill,
      border: border ?? this.border,
      text: text ?? this.text,
    );
  }

  @override
  DefenseBadgeTheme lerp(ThemeExtension<DefenseBadgeTheme>? other, double t) {
    if (other is! DefenseBadgeTheme) return this;
    return DefenseBadgeTheme(
      fill: Color.lerp(fill, other.fill, t)!,
      border: Color.lerp(border, other.border, t)!,
      text: Color.lerp(text, other.text, t)!,
    );
  }
}

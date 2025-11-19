// lib/ui/theme/badge_theme.dart
import 'package:flutter/material.dart';

/// ThemeExtension para padronizar as cores do "badge de nível"
@immutable
class BadgeTheme extends ThemeExtension<BadgeTheme> {
  final Color fill;
  final Color border;
  final Color text;

  const BadgeTheme({
    required this.fill,
    required this.border,
    required this.text,
  });

  @override
  BadgeTheme copyWith({Color? fill, Color? border, Color? text}) {
    return BadgeTheme(
      fill: fill ?? this.fill,
      border: border ?? this.border,
      text: text ?? this.text,
    );
  }

  @override
  BadgeTheme lerp(ThemeExtension<BadgeTheme>? other, double t) {
    if (other is! BadgeTheme) return this;
    return BadgeTheme(
      fill: Color.lerp(fill, other.fill, t)!,
      border: Color.lerp(border, other.border, t)!,
      text: Color.lerp(text, other.text, t)!,
    );
  }
}

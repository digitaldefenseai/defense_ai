// lib/ui/theme/responsive.dart
import 'package:flutter/material.dart';

/// Breakpoints & helpers de responsividade
class BR {
  // ---------- Breakpoints ----------
  static bool isSmall(BuildContext c) => MediaQuery.of(c).size.width < 600;
  static bool isMedium(BuildContext c) {
    final w = MediaQuery.of(c).size.width;
    return w >= 600 && w < 900;
  }
  static bool isLarge(BuildContext c) => MediaQuery.of(c).size.width >= 900;

  // ---------- Viewport units ----------
  static double vh(BuildContext c, double percent) =>
      MediaQuery.of(c).size.height * (percent / 100);
  static double vw(BuildContext c, double percent) =>
      MediaQuery.of(c).size.width * (percent / 100);

  // ---------- Content max width ----------
  static const double contentMaxWidth = 900;

  // ---------- Spacers (SizedBox) ----------
  static SizedBox spacerXS(BuildContext c) => SizedBox(height: spaceXS(c));
  static SizedBox spacerS(BuildContext c)  => SizedBox(height: spaceS(c));
  static SizedBox spacerM(BuildContext c)  => SizedBox(height: spaceM(c));
  static SizedBox spacerL(BuildContext c)  => SizedBox(height: spaceL(c));
  static SizedBox spacerXL(BuildContext c) => SizedBox(height: spaceXL(c));

  // ---------- Valores numéricos (double) ----------
  static double spaceXS(BuildContext c) => isSmall(c) ? 6  : isMedium(c) ? 8  : 10;
  static double spaceS (BuildContext c) => isSmall(c) ? 8  : isMedium(c) ? 12 : 14;
  static double spaceM (BuildContext c) => isSmall(c) ? 12 : isMedium(c) ? 16 : 20;
  static double spaceL (BuildContext c) => isSmall(c) ? 16 : isMedium(c) ? 20 : 24;
  static double spaceXL(BuildContext c) => isSmall(c) ? 24 : isMedium(c) ? 28 : 32;

  // ---------- Altura da logo com clamp + escala ----------
  // 'scale' permite aumentar/diminuir sem explodir em telas muito altas.
  static double logoHeight(BuildContext c, {double scale = 1.0}) {
    final h = MediaQuery.of(c).size.height;
    // alvo base = 20% da altura da tela
    final target = h * 0.20;
    // clamp manual para manter entre 220 e 380
    double clamped;
    if (target < 220.0) {
      clamped = 220.0;
    } else if (target > 380.0) {
      clamped = 380.0;
    } else {
      clamped = target;
    }
    return clamped * scale;
  }

  // ---------- Padding de tela ----------
  static EdgeInsets screenPadding(BuildContext c) {
    final base = isSmall(c) ? 16.0 : isMedium(c) ? 20.0 : 24.0;
    final top  = isSmall(c) ?  8.0 : isMedium(c) ? 12.0 : 16.0;
    return EdgeInsets.fromLTRB(base, top, base, base);
  }

  // ---------- Ícones/Padding de cards ----------
  static double cardIconSize(BuildContext c) =>
      isSmall(c) ? 32 : isMedium(c) ? 36 : 40;

  static EdgeInsets cardPadding(BuildContext c) =>
      EdgeInsets.all(isSmall(c) ? 14 : isMedium(c) ? 16 : 20);

  // ---------- Espaçamentos do grid ----------
  static double gridMainAxisSpacing(BuildContext c) => isSmall(c) ? 12 : 16;
  static double gridCrossAxisSpacing(BuildContext c) => isSmall(c) ? 12 : 16;
}

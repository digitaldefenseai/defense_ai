import 'package:flutter/material.dart';
import 'package:defense_ai/ui/theme/brand_assets.dart';

/// AppBar padrão com a marca (ícone tema-aware à esquerda)
class BrandAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final double elevation;

  const BrandAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = false,
    this.elevation = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AppBar(
      elevation: elevation,
      backgroundColor: cs.surface,
      title: Text(title),
      centerTitle: centerTitle,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: Image.asset(
          Brand.iconByTheme(context), // alterna claro/escuro
          width: 24,
          height: 24,
          filterQuality: FilterQuality.high,
          isAntiAlias: true,
          errorBuilder: (_, __, ___) => const Icon(Icons.shield_outlined),
        ),
      ),
      leadingWidth: 44,
      actions: actions,
    );
  }
}

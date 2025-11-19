// lib/ui/widgets/content_shell.dart
import 'package:flutter/material.dart';
import 'package:defense_ai/ui/theme/responsive.dart';

class ContentShell extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets? padding;

  const ContentShell({
    super.key,
    required this.child,
    this.maxWidth = BR.contentMaxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: SingleChildScrollView(
            padding: padding ?? BR.screenPadding(context),
            child: child,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AppShellStyles {
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color border(BuildContext context) {
    return isDark(context) ? const Color(0xFF2D3444) : const Color(0xFFDCE1EB);
  }

  static Color mutedSurface(BuildContext context) {
    return isDark(context) ? const Color(0xFF202634) : const Color(0xFFF1F3F8);
  }

  static Color cardSurface(BuildContext context) {
    return isDark(context) ? const Color(0xFF171B24) : const Color(0xFFFFFFFF);
  }

  static Color mutedText(BuildContext context) {
    return isDark(context) ? const Color(0xFF9AA4B7) : const Color(0xFF6B7280);
  }

  static Color accent(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }

  static BoxDecoration glassCard(
    BuildContext context, {
    Color? tint,
    double radius = 24,
    bool highlighted = false,
  }) {
    final baseColor = cardSurface(context);
    final outlineColor = border(context);
    final bool dark = isDark(context);

    return BoxDecoration(
      color: tint == null
          ? baseColor
          : Color.alphaBlend(
              tint.withValues(alpha: dark ? 0.08 : 0.05),
              baseColor,
            ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: highlighted
            ? accent(context).withValues(alpha: dark ? 0.42 : 0.28)
            : outlineColor,
      ),
      boxShadow: [
        if (!isDark(context))
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
      ],
    );
  }

  static Decoration pageBackground(BuildContext context) {
    final bool dark = isDark(context);
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return BoxDecoration(
      color: bg,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [dark ? const Color(0xFF141925) : const Color(0xFFFCFDFE), bg],
      ),
    );
  }
}

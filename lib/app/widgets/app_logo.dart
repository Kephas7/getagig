import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double? height;
  final double? width;
  final BoxFit fit;
  final bool forceLight;

  const AppLogo({
    super.key,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
    this.forceLight = false,
  });

  String _assetPath(BuildContext context) {
    if (forceLight) {
      return 'assets/images/logo(light).png';
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? 'assets/images/logo(dark).png'
        : 'assets/images/logo(light).png';
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _assetPath(context),
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.music_note_rounded, size: 64);
      },
    );
  }
}

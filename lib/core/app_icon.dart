import 'package:flutter/material.dart';

/// Renders a custom PNG icon from assets/icons/ tinted to match the
/// surrounding [Icon] usages it replaces.
class AppAssetIcon extends StatelessWidget {
  final String asset;
  final double size;
  final Color? color;

  const AppAssetIcon(this.asset, {super.key, required this.size, this.color});

  @override
  Widget build(BuildContext context) {
    final tint = color ?? IconTheme.of(context).color ?? Colors.black;
    return Image.asset(asset, width: size, height: size, color: tint, colorBlendMode: BlendMode.srcIn);
  }
}

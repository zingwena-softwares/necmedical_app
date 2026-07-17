import 'package:flutter/material.dart';

/// Fixed brand colors matching the NEC Medical dual-tone (navy + teal)
/// mockup. These sit alongside the Material [ColorScheme] in main.dart —
/// use these for the specific navy/teal brand surfaces (hero, portal
/// cards, accent icons), and colorScheme.* for everything that must
/// adapt to light/dark mode (page background, body text, plain cards).
class AppColors {
  AppColors._();

  static const navy = Color(0xFF152452);
  static const navyLight = Color(0xFF223B7A);
  static const teal = Color(0xFF12A28D);
  static const tealDark = Color(0xFF0C8577);

  static const noticeCardBg = Color(0xFFE6F6F3);
  static const aboutCardBg = Color(0xFFF1F1F6);

  static const iconBgLavender = Color(0xFFEDEAFB);
  static const iconLavender = Color(0xFF6C63FF);

  static const iconBgTeal = Color(0xFFDAF5F0);
  static const iconTeal = Color(0xFF12A28D);

  static const iconBgViolet = Color(0xFFF1E6FA);
  static const iconViolet = Color(0xFF9B51E0);

  static const iconBgBlue = Color(0xFFE3F0FE);
  static const iconBlue = Color(0xFF2F80ED);

  static const badgeRed = Color(0xFFEF4444);
}

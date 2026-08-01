import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Shared "nicer" field decoration for every Employer Portal form — filled,
/// borderless by default, brand-colored focus ring. Used by every TextField
/// and DropdownButtonFormField in the Employer Portal so forms read as one
/// consistent, polished surface instead of a grab-bag of default Material
/// outlined fields.
InputDecoration employerFieldDecoration(
  BuildContext context, {
  required String label,
  String? hint,
  IconData? icon,
  Widget? suffixIcon,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: icon != null ? Icon(icon, size: 20, color: colorScheme.onSurfaceVariant) : null,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.navy, width: 1.6),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.badgeRed, width: 1.2),
    ),
    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
  );
}

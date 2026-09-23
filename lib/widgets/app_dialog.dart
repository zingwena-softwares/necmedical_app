import 'package:flutter/material.dart';
import '../core/app_colors.dart';

/// Shared dialog shell used everywhere instead of a bare [AlertDialog] —
/// icon in a soft tinted circle, centered title/message, rounded corners,
/// and full-width side-by-side actions so every confirm/info popup in the
/// app reads as one consistent, deliberate design rather than a default
/// system dialog.
class AppDialog {
  AppDialog._();

  /// Shows a two-button confirm dialog and resolves `true`/`false`. Use
  /// [destructive] for anything that removes/ends something (delete,
  /// log out) to tint the icon and confirm button red.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    IconData icon = Icons.help_outline_rounded,
    bool destructive = false,
  }) async {
    final accent = destructive ? AppColors.badgeRed : AppColors.navy;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _AppDialogShell(
        icon: icon,
        iconColor: accent,
        title: title,
        body: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, height: 1.4, color: Theme.of(dialogContext).colorScheme.onSurfaceVariant),
        ),
        actions: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(dialogContext).colorScheme.onSurface,
                side: BorderSide(color: Theme.of(dialogContext).colorScheme.outlineVariant),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(cancelLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(confirmLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Shows a single-action info/success dialog with an arbitrary [body]
  /// (e.g. a highlighted reference number box).
  static Future<void> show(
    BuildContext context, {
    required String title,
    required Widget body,
    String actionLabel = 'Done',
    IconData icon = Icons.check_circle_outline_rounded,
    Color iconColor = AppColors.tealDark,
    bool barrierDismissible = false,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) => _AppDialogShell(
        icon: icon,
        iconColor: iconColor,
        title: title,
        body: body,
        actions: [
          Expanded(
            child: FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.navy,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(actionLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppDialogShell extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget body;
  final List<Widget> actions;

  const _AppDialogShell({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: colorScheme.onSurface)),
            const SizedBox(height: 10),
            body,
            const SizedBox(height: 22),
            Row(children: actions),
          ],
        ),
      ),
    );
  }
}

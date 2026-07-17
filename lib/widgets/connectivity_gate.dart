import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../core/app_colors.dart';
import '../core/connectivity_provider.dart';

/// Sits above the whole app (via [MaterialApp.builder]) and overlays a
/// full-screen "No Internet" state whenever connectivity drops — without
/// tearing down whatever screen is underneath, so nothing resets or
/// re-fetches when the connection comes back.
class ConnectivityGate extends ConsumerWidget {
  final Widget child;
  const ConnectivityGate({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(connectivityProvider);
    // Optimistic default: don't flash the offline screen while the very
    // first connectivity check is still in flight at cold start.
    final isOffline = status.maybeWhen(data: (isOnline) => !isOnline, orElse: () => false);

    return Stack(
      children: [
        child,
        IgnorePointer(
          ignoring: !isOffline,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (widget, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(animation),
                child: widget,
              ),
            ),
            child: isOffline ? const _NoInternetScreen(key: ValueKey('offline')) : const SizedBox.shrink(key: ValueKey('online')),
          ),
        ),
      ],
    );
  }
}

class _NoInternetScreen extends ConsumerWidget {
  const _NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: AspectRatio(
                  // Matches the animation's own composition size so it
                  // never has to reflow while (or after) it loads.
                  aspectRatio: 800 / 1100,
                  child: Lottie.asset(
                    'assets/animations/no_internet.json',
                    repeat: true,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No Internet Connection',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: colorScheme.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                "You're offline. Check your connection\nand we'll reconnect automatically.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, height: 1.4, color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => ref.invalidate(connectivityProvider),
                  child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

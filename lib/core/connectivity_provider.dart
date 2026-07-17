import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Debounced online/offline status for the whole app.
///
/// The raw [InternetConnection] stream can flip rapidly on flaky networks
/// (wifi hand-off, captive portals, DNS blips), which would otherwise make
/// the offline screen flash in and out. "Offline" is surfaced the instant
/// it's detected, but a short stable window is required before switching
/// back to "online" so the UI doesn't flicker while the connection is still
/// settling.
final connectivityProvider = StreamProvider<bool>((ref) {
  final controller = StreamController<bool>();
  Timer? recoveryDebounce;

  final subscription = InternetConnection().onStatusChange.listen((status) {
    final isOnline = status == InternetStatus.connected;
    recoveryDebounce?.cancel();
    if (!isOnline) {
      controller.add(false);
    } else {
      recoveryDebounce = Timer(const Duration(milliseconds: 800), () {
        controller.add(true);
      });
    }
  });

  ref.onDispose(() {
    recoveryDebounce?.cancel();
    subscription.cancel();
    controller.close();
  });

  return controller.stream;
});

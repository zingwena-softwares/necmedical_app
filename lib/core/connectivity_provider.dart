import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Debounced online/offline status for the whole app.
///
/// The raw [InternetConnection] stream can flip rapidly on flaky networks
/// (wifi hand-off, captive portals, DNS blips), which would otherwise make
/// the offline screen flash in and out. Cold app start is the worst case —
/// the very first reachability check can fail before the OS radio/DNS
/// resolver has fully woken up, even though the connection is actually fine
/// a moment later. So both transitions require a short stable window before
/// they're surfaced: offline gets a short one (real disconnects still show
/// quickly), online gets a longer one (avoids flicker while the connection
/// is still settling).
final connectivityProvider = StreamProvider<bool>((ref) {
  final controller = StreamController<bool>();
  Timer? debounce;

  final subscription = InternetConnection().onStatusChange.listen((status) {
    final isOnline = status == InternetStatus.connected;
    debounce?.cancel();
    if (!isOnline) {
      debounce = Timer(const Duration(milliseconds: 1500), () {
        controller.add(false);
      });
    } else {
      debounce = Timer(const Duration(milliseconds: 800), () {
        controller.add(true);
      });
    }
  });

  ref.onDispose(() {
    debounce?.cancel();
    subscription.cancel();
    controller.close();
  });

  return controller.stream;
});

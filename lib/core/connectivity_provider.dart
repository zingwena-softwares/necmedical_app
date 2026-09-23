import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// The package's own defaults (3s timeout per host) are too impatient on a
/// mobile connection that's still waking up — a cold app launch, a radio
/// coming back from doze, a DNS resolver that hasn't warmed up yet — so all
/// of them can time out within that window even though the device is
/// genuinely online a moment later (reproduced directly: every default host
/// failed simultaneously on a connection that answered `ping` fine seconds
/// before). Real disconnects don't get any less real with a longer timeout;
/// this only removes false positives on a slow-to-wake connection.
///
/// One check is our own backend — if that's unreachable the app can't do
/// anything useful anyway, so it doubles as a meaningful signal rather than
/// just a generic "is the internet up" ping.
final _connectionChecker = InternetConnection.createInstance(
  checkInterval: const Duration(seconds: 10),
  useDefaultOptions: false,
  customCheckOptions: [
    InternetCheckOption(uri: Uri.parse('https://necmedical.org.zw'), timeout: const Duration(seconds: 8)),
    InternetCheckOption(uri: Uri.parse('https://one.one.one.one'), timeout: const Duration(seconds: 8)),
    InternetCheckOption(uri: Uri.parse('https://icanhazip.com'), timeout: const Duration(seconds: 8)),
    InternetCheckOption(
      uri: Uri.parse('https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js'),
      timeout: const Duration(seconds: 8),
    ),
    InternetCheckOption(uri: Uri.parse('https://captive.apple.com/internet-check'), timeout: const Duration(seconds: 8)),
  ],
);

/// Debounced online/offline status for the whole app.
///
/// The raw [InternetConnection] stream can still flip rapidly on flaky
/// networks (wifi hand-off, captive portals, brief DNS blips) even with the
/// longer per-host timeouts above, which would otherwise make the offline
/// screen flash in and out. So both transitions require a short stable
/// window before they're surfaced: offline gets a short one (real
/// disconnects still show quickly), online gets a longer one (avoids
/// flicker while the connection is still settling).
final connectivityProvider = StreamProvider<bool>((ref) {
  final controller = StreamController<bool>();
  Timer? debounce;

  final subscription = _connectionChecker.onStatusChange.listen((status) {
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

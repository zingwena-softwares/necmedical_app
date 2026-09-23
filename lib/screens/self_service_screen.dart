import 'package:flutter/material.dart';
import 'self_service/self_service_home_screen.dart';

/// Entry point for Self Service. Case/report submission and tracking are
/// public endpoints on the selfservice.necmedical.org.zw API — no login or
/// token bootstrap needed, so this just goes straight to the home screen.
class SelfServiceScreen extends StatelessWidget {
  const SelfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) => const SelfServiceHomeScreen();
}

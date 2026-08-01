import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/employer/employer_auth_state.dart';
import '../providers/employer/employer_providers.dart';
import 'employer/employer_dashboard_screen.dart';
import 'employer/employer_login_screen.dart';

/// Routes to the Employer Portal login screen or dashboard depending on
/// whether there's a valid saved session — see DEVELOPER_INTEGRATION_GUIDE.md
/// (Ardent Tech, 2026-07-31) for the API this now talks to natively.
class EmployerPortalScreen extends ConsumerWidget {
  const EmployerPortalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(employerAuthProvider);
    switch (auth.status) {
      case EmployerAuthStatus.checking:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case EmployerAuthStatus.loggedOut:
        return const EmployerLoginScreen();
      case EmployerAuthStatus.loggedIn:
        return const EmployerDashboardScreen();
    }
  }
}

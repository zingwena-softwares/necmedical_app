import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../providers/self_service/self_service_employer_providers.dart';
import 'employer_register_screen.dart';
import 'employer_self_service_home_screen.dart';
import 'employer_sign_in_screen.dart';

/// Routes to the employer's Self Service home if they're already signed
/// in, or a Sign In / Register choice otherwise — mirrors the "Employer
/// Portal" section on the selfservice.necmedical.org.zw website.
class EmployerPortalEntryScreen extends ConsumerWidget {
  const EmployerPortalEntryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(selfServiceEmployerAuthProvider);
    switch (auth.status) {
      case SelfServiceEmployerStatus.checking:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case SelfServiceEmployerStatus.loggedIn:
        return EmployerSelfServiceHomeScreen(employer: auth.employer!);
      case SelfServiceEmployerStatus.loggedOut:
        return const _EmployerPortalChoiceScreen();
    }
  }
}

class _EmployerPortalChoiceScreen extends StatelessWidget {
  const _EmployerPortalChoiceScreen();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(title: const Text('Employer Portal')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.navy, AppColors.navyLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.apartment_rounded, color: AppColors.navy, size: 20),
                ),
                const SizedBox(height: 10),
                const Text('Employer Portal', style: TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                const Text('Register your organisation to view levies, billings and payments',
                    style: TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _ActionCard(
            icon: Icons.login_rounded,
            iconBg: AppColors.iconBgBlue,
            iconColor: AppColors.iconBlue,
            title: 'Sign In',
            subtitle: 'Already registered? Access your account',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmployerSignInScreen())),
          ),
          const SizedBox(height: 10),
          _ActionCard(
            icon: Icons.domain_add_rounded,
            iconBg: AppColors.iconBgTeal,
            iconColor: AppColors.iconTeal,
            title: 'Register Employer',
            subtitle: 'Register your business with NEC Medical',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmployerRegisterScreen())),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, size: 21, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: colorScheme.onSurface, fontSize: 14.5, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11.5)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

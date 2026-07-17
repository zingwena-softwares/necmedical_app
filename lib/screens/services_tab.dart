import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_icon.dart';
import 'employer_portal_screen.dart';
import 'self_service_screen.dart';

class ServicesTab extends StatelessWidget {
  const ServicesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Services')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ServicePortalCard(
              gradientStart: AppColors.navy,
              gradientEnd: AppColors.navyLight,
              label: 'EMPLOYER SERVICES',
              title: 'Employer Portal',
              iconAsset: 'assets/icons/employee_portal_icon.png',
              features: const ['Statements', 'Returns', 'Payments', 'Employee Management'],
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmployerPortalScreen())),
            ),
            const SizedBox(height: 16),
            _ServicePortalCard(
              gradientStart: AppColors.tealDark,
              gradientEnd: AppColors.teal,
              label: 'EMPLOYEE SERVICES',
              title: 'Self Service',
              iconAsset: 'assets/icons/self_service_portal.png',
              features: const ['Cases & Disputes', 'Hearings', 'Arbitration', 'Case Tracking'],
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SelfServiceScreen())),
            ),
            const SizedBox(height: 16),
            Text(
              'More services (returns submission, payments history, case forms) will appear here once the '
              'Employer Portal and Self Service APIs are wired up.',
              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServicePortalCard extends StatelessWidget {
  final Color gradientStart;
  final Color gradientEnd;
  final String label;
  final String title;
  final String iconAsset;
  final List<String> features;
  final VoidCallback onTap;

  const _ServicePortalCard({
    required this.gradientStart,
    required this.gradientEnd,
    required this.label,
    required this.title,
    required this.iconAsset,
    required this.features,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [gradientStart, gradientEnd], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label,
                    style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), shape: BoxShape.circle),
                child: Center(child: AppAssetIcon(iconAsset, size: 18, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ...features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, size: 15, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(f, style: const TextStyle(color: Colors.white, fontSize: 13)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Access Portal', style: TextStyle(color: gradientStart, fontSize: 13, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded, size: 11, color: gradientStart),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

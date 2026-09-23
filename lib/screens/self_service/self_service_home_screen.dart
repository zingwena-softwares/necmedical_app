import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import 'employer_portal_entry_screen.dart';
import 'submit_case_screen.dart';
import 'submit_report_screen.dart';
import 'track_case_screen.dart';

class SelfServiceHomeScreen extends StatelessWidget {
  const SelfServiceHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(title: const Text('Self Service')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.tealDark, AppColors.teal], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.support_agent_rounded, color: AppColors.tealDark, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cases & Disputes',
                          style: const TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text('Submit a complaint or check on one you already sent',
                          style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text('What would you like to do?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
          const SizedBox(height: 10),
          _ActionCard(
            icon: Icons.add_circle_outline_rounded,
            iconBg: AppColors.iconBgTeal,
            iconColor: AppColors.iconTeal,
            title: 'Submit a Case',
            subtitle: 'Raise a formal dispute against your employer',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubmitCaseScreen())),
          ),
          const SizedBox(height: 10),
          _ActionCard(
            icon: Icons.report_gmailerrorred_rounded,
            iconBg: AppColors.iconBgViolet,
            iconColor: AppColors.iconViolet,
            title: 'Submit a Report',
            subtitle: 'Report a complaint, workplace accident or harassment',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubmitReportScreen())),
          ),
          const SizedBox(height: 10),
          _ActionCard(
            icon: Icons.search_rounded,
            iconBg: AppColors.iconBgBlue,
            iconColor: AppColors.iconBlue,
            title: 'Track My Case',
            subtitle: 'Check a case\'s status with its case number',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackCaseScreen())),
          ),
          const SizedBox(height: 28),
          Text('Employer Portal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
          const SizedBox(height: 4),
          Text('For businesses registering with NEC Medical and viewing their levy account',
              style: TextStyle(fontSize: 11.5, color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 10),
          _ActionCard(
            icon: Icons.apartment_rounded,
            iconBg: AppColors.iconBgLavender,
            iconColor: AppColors.iconLavender,
            title: 'Employer Portal',
            subtitle: 'Register your business, or sign in to view levies & payments',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmployerPortalEntryScreen())),
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

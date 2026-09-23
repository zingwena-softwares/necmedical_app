import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../providers/employer/employer_data_providers.dart';
import '../../providers/employer/employer_providers.dart';
import '../../widgets/app_dialog.dart';
import 'employees_screen.dart';
import 'invoices_screen.dart';
import 'payment_proofs_screen.dart';
import 'payments_screen.dart';
import 'returns_screen.dart';
import 'statements_screen.dart';

class EmployerDashboardScreen extends ConsumerWidget {
  const EmployerDashboardScreen({super.key});

  static String _iso(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(employerAuthProvider);
    final institution = auth.institution;
    final colorScheme = Theme.of(context).colorScheme;

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    final statements = ref.watch(statementsProvider((dateFrom: _iso(monthStart), dateTo: _iso(monthEnd), currency: 2)));
    final invoices = ref.watch(invoicesProvider((dateFrom: _iso(DateTime(now.year, 1, 1)), dateTo: _iso(DateTime(now.year, 12, 31)), currency: 2)));
    final employees = ref.watch(employeesProvider(''));

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainerLowest,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Employer Portal'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Log out',
              onPressed: () => _confirmLogout(context, ref),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.navy, AppColors.navyLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.business_center_rounded, color: AppColors.navy, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(institution?.tradeName ?? 'Employer',
                            style: const TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text('Account: ${institution?.accountNumber ?? '-'}',
                            style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'This Month',
                    value: statements.maybeWhen(data: (r) => r.summary.closingBalance.toStringAsFixed(2), orElse: () => '—'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatTile(
                    icon: Icons.pending_actions_outlined,
                    label: 'Outstanding',
                    value: invoices.maybeWhen(data: (r) => r.summary.balanceTotal.toStringAsFixed(2), orElse: () => '—'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatTile(
                    icon: Icons.groups_outlined,
                    label: 'Employees',
                    value: employees.maybeWhen(data: (r) => '${r.count}', orElse: () => '—'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text('Quick Actions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.7,
              children: [
                _ActionTile(
                  icon: Icons.receipt_long_rounded,
                  iconBg: AppColors.iconBgBlue,
                  iconColor: AppColors.iconBlue,
                  title: 'Statements',
                  subtitle: 'View & download',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatementsScreen())),
                ),
                _ActionTile(
                  icon: Icons.assignment_turned_in_rounded,
                  iconBg: AppColors.iconBgTeal,
                  iconColor: AppColors.iconTeal,
                  title: 'Returns',
                  subtitle: 'Submit & review',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReturnsScreen())),
                ),
                _ActionTile(
                  icon: Icons.description_rounded,
                  iconBg: AppColors.iconBgLavender,
                  iconColor: AppColors.iconLavender,
                  title: 'Invoices',
                  subtitle: 'Balances due',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InvoicesScreen())),
                ),
                _ActionTile(
                  icon: Icons.payments_rounded,
                  iconBg: AppColors.iconBgViolet,
                  iconColor: AppColors.iconViolet,
                  title: 'Payments',
                  subtitle: 'Payment history',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentsScreen())),
                ),
                _ActionTile(
                  icon: Icons.groups_rounded,
                  iconBg: AppColors.iconBgBlue,
                  iconColor: AppColors.iconBlue,
                  title: 'Employees',
                  subtitle: 'Manage staff',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmployeesScreen())),
                ),
                _ActionTile(
                  icon: Icons.upload_file_rounded,
                  iconBg: AppColors.iconBgTeal,
                  iconColor: AppColors.iconTeal,
                  title: 'Payment Proofs',
                  subtitle: 'Upload & track',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentProofsScreen())),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppDialog.confirm(
      context,
      title: 'Log out?',
      message: 'You\'ll need to log in again to access the Employer Portal.',
      icon: Icons.logout_rounded,
      confirmLabel: 'Log Out',
      destructive: true,
    );
    if (confirmed) ref.read(employerAuthProvider.notifier).logout();
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.navy),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.navy)),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 9.5, color: colorScheme.onSurfaceVariant), maxLines: 1),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
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
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, size: 17, color: iconColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title,
                        style: TextStyle(color: colorScheme.onSurface, fontSize: 12.5, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 1),
                    Text(subtitle,
                        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

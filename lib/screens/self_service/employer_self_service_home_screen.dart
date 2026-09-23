import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../models/self_service/employer_account_model.dart';
import '../../models/self_service/levy_model.dart';
import '../../providers/self_service/self_service_data_providers.dart';
import '../../providers/self_service/self_service_employer_providers.dart';
import '../../widgets/app_dialog.dart';

class EmployerSelfServiceHomeScreen extends ConsumerWidget {
  const EmployerSelfServiceHomeScreen({super.key, required this.employer});

  final EmployerAccount employer;

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppDialog.confirm(
      context,
      title: 'Log out?',
      message: 'You\'ll need to sign in again to view your levies and payments.',
      icon: Icons.logout_rounded,
      confirmLabel: 'Log Out',
      destructive: true,
    );
    if (confirmed) ref.read(selfServiceEmployerAuthProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final balance = ref.watch(selfServiceLeviesBalanceProvider);
    final levies = ref.watch(selfServiceLeviesProvider);
    final payments = ref.watch(selfServiceLevyPaymentsProvider);

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
              padding: const EdgeInsets.all(18),
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
                        Text(employer.tradeName,
                            style: const TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(
                          employer.status == 'pending' ? 'Registration pending approval' : (employer.status ?? ''),
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            balance.when(
              data: (b) => Row(
                children: [
                  Expanded(child: _StatTile(label: 'Billed', value: b.totalBilled)),
                  const SizedBox(width: 10),
                  Expanded(child: _StatTile(label: 'Paid', value: b.totalPaid)),
                  const SizedBox(width: 10),
                  Expanded(child: _StatTile(label: 'Owing', value: b.totalOwing)),
                ],
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Couldn\'t load balance: $e', style: const TextStyle(color: AppColors.badgeRed, fontSize: 12)),
            ),
            const SizedBox(height: 22),
            Text('Levies', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
            const SizedBox(height: 10),
            levies.when(
              data: (list) => list.isEmpty
                  ? _EmptyCard(text: 'No levies recorded yet.')
                  : Column(children: list.map((l) => _LevyTile(levy: l)).toList()),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Couldn\'t load levies: $e', style: const TextStyle(color: AppColors.badgeRed, fontSize: 12)),
            ),
            const SizedBox(height: 22),
            Text('Payments', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
            const SizedBox(height: 10),
            payments.when(
              data: (list) => list.isEmpty
                  ? _EmptyCard(text: 'No payments recorded yet.')
                  : Column(children: list.map((p) => _PaymentTile(payment: p)).toList()),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Couldn\'t load payments: $e', style: const TextStyle(color: AppColors.badgeRed, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final double value;
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value.toStringAsFixed(2), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.navy)),
          ),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String text;
  const _EmptyCard({required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.noticeCardBg, borderRadius: BorderRadius.circular(14)),
      child: Text(text, style: TextStyle(fontSize: 12.5, color: colorScheme.onSurfaceVariant)),
    );
  }
}

class _LevyTile extends StatelessWidget {
  final Levy levy;
  const _LevyTile({required this.levy});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(levy.description ?? levy.period ?? 'Levy #${levy.id}',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
                if (levy.status != null) ...[
                  const SizedBox(height: 3),
                  Text(levy.status!, style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                ],
              ],
            ),
          ),
          Text('${levy.amountOwing.toStringAsFixed(2)} owing',
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.badgeRed)),
        ],
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final LevyPayment payment;
  const _PaymentTile({required this.payment});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(payment.reference != null ? 'Ref: ${payment.reference}' : 'Payment #${payment.id}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
          ),
          Text(payment.amount.toStringAsFixed(2),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.tealDark)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../providers/employer/employer_data_providers.dart';
import '../../widgets/shimmer_box.dart';
import 'upload_payment_proof_screen.dart';

class PaymentProofsScreen extends ConsumerStatefulWidget {
  const PaymentProofsScreen({super.key});

  @override
  ConsumerState<PaymentProofsScreen> createState() => _PaymentProofsScreenState();
}

class _PaymentProofsScreenState extends ConsumerState<PaymentProofsScreen> {
  String _status = '';

  static const _statuses = ['', 'pending', 'accepted', 'declined'];

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return AppColors.iconTeal;
      case 'declined':
        return AppColors.badgeRed;
      default:
        return AppColors.iconBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final proofs = ref.watch(paymentProofsProvider(_status));

    return Scaffold(
      appBar: AppBar(title: const Text('Payment Proofs')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.navy,
        onPressed: () async {
          final uploaded = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const UploadPaymentProofScreen()),
          );
          if (uploaded == true) ref.invalidate(paymentProofsProvider(_status));
        },
        icon: const Icon(Icons.upload_file_rounded),
        label: const Text('Upload'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _statuses.map((s) {
                  final selected = s == _status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(s.isEmpty ? 'All' : s[0].toUpperCase() + s.substring(1)),
                      selected: selected,
                      onSelected: (_) => setState(() => _status = s),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: proofs.when(
              loading: () => AppShimmer(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: List.generate(
                    4,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ShimmerBox(width: double.infinity, height: 60, borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
              error: (e, _) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('$e'))),
              data: (result) {
                if (result.rows.isEmpty) {
                  return const Center(child: Text('No payment proofs uploaded yet.'));
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                  children: result.rows.map((proof) => Container(
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
                                  Text(proof.amount.toStringAsFixed(2),
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: colorScheme.onSurface)),
                                  if (proof.paymentDate != null) ...[
                                    const SizedBox(height: 3),
                                    Text('${proof.paymentDate!.day}/${proof.paymentDate!.month}/${proof.paymentDate!.year}',
                                        style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                                  ],
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: _statusColor(proof.status).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                proof.status.toUpperCase(),
                                style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: _statusColor(proof.status)),
                              ),
                            ),
                          ],
                        ),
                      ))
                      .toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

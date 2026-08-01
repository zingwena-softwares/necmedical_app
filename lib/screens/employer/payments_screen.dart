import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../providers/employer/employer_data_providers.dart';
import '../../widgets/employer/date_range_currency_filter.dart';
import '../../widgets/shimmer_box.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  late DateTime _dateFrom;
  late DateTime _dateTo;
  int _currency = 2;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateFrom = DateTime(now.year, 1, 1);
    _dateTo = DateTime(now.year, 12, 31);
  }

  String _iso(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  DateRangeCurrency get _args => (dateFrom: _iso(_dateFrom), dateTo: _iso(_dateTo), currency: _currency);

  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _dateFrom : _dateTo,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _dateFrom = picked;
      } else {
        _dateTo = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final payments = ref.watch(paymentsProvider(_args));

    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: Column(
        children: [
          DateRangeCurrencyFilter(
            dateFrom: _dateFrom,
            dateTo: _dateTo,
            currency: _currency,
            onPickDate: (isFrom) => _pickDate(isFrom: isFrom),
            onCurrencyChanged: (v) => setState(() => _currency = v),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: payments.when(
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
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('No payments recorded for this period.',
                          textAlign: TextAlign.center, style: TextStyle(color: colorScheme.onSurfaceVariant)),
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.noticeCardBg, borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                          Text('Total Paid', style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                          const Spacer(),
                          Text(result.summary.totalAmount.toStringAsFixed(2),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.tealDark)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...result.rows.map((payment) => Container(
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
                                    Text(payment.reference != null ? 'Ref: ${payment.reference}' : 'Payment #${payment.id}',
                                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
                                    if (payment.paymentDate != null) ...[
                                      const SizedBox(height: 3),
                                      Text('${payment.paymentDate!.day}/${payment.paymentDate!.month}/${payment.paymentDate!.year}',
                                          style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                                    ],
                                  ],
                                ),
                              ),
                              Text(payment.amount.toStringAsFixed(2),
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: colorScheme.onSurface)),
                            ],
                          ),
                        )),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

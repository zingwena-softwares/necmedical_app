import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../providers/employer/employer_data_providers.dart';
import '../../widgets/employer/date_range_currency_filter.dart';
import '../../widgets/shimmer_box.dart';

class InvoicesScreen extends ConsumerStatefulWidget {
  const InvoicesScreen({super.key});

  @override
  ConsumerState<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends ConsumerState<InvoicesScreen> {
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
    final invoices = ref.watch(invoicesProvider(_args));

    return Scaffold(
      appBar: AppBar(title: const Text('Invoices')),
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
            child: invoices.when(
              loading: () => AppShimmer(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: List.generate(
                    6,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ShimmerBox(width: double.infinity, height: 70, borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
              error: (e, _) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('$e'))),
              data: (result) {
                if (result.rows.isEmpty) {
                  return const Center(child: Text('No invoices for this period.'));
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.noticeCardBg, borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                          Expanded(
                            child: _summaryTile('Invoiced', result.summary.invoiceTotal, colorScheme),
                          ),
                          Expanded(
                            child: _summaryTile('Paid', result.summary.amountPaid, colorScheme),
                          ),
                          Expanded(
                            child: _summaryTile('Balance', result.summary.balanceTotal, colorScheme),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...result.rows.map((invoice) => Container(
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
                                    Text('Invoice #${invoice.id}',
                                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
                                    const SizedBox(height: 3),
                                    Text(invoice.remarks, style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                                    const SizedBox(height: 3),
                                    Text('${invoice.invoiceDate.day}/${invoice.invoiceDate.month}/${invoice.invoiceDate.year}',
                                        style: TextStyle(fontSize: 10.5, color: colorScheme.onSurfaceVariant)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(invoice.invoiceTotal.toStringAsFixed(2),
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: colorScheme.onSurface)),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: invoice.isPaid ? AppColors.iconBgTeal : AppColors.iconBgBlue,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      invoice.isPaid ? 'PAID' : 'Bal ${invoice.balance.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: invoice.isPaid ? AppColors.iconTeal : AppColors.iconBlue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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

  Widget _summaryTile(String label, double value, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10.5, color: colorScheme.onSurfaceVariant)),
        const SizedBox(height: 3),
        Text(value.toStringAsFixed(2), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.navy)),
      ],
    );
  }
}

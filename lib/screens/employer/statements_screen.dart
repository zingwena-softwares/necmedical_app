import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/app_colors.dart';
import '../../core/employer_api_client.dart';
import '../../providers/employer/employer_data_providers.dart';
import '../../providers/employer/employer_providers.dart';
import '../../widgets/employer/date_range_currency_filter.dart';
import '../../widgets/shimmer_box.dart';

class StatementsScreen extends ConsumerStatefulWidget {
  const StatementsScreen({super.key});

  @override
  ConsumerState<StatementsScreen> createState() => _StatementsScreenState();
}

class _StatementsScreenState extends ConsumerState<StatementsScreen> {
  late DateTime _dateFrom;
  late DateTime _dateTo;
  int _currency = 2;
  bool _busy = false;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateFrom = DateTime(now.year, now.month, 1);
    _dateTo = DateTime(now.year, now.month + 1, 0);
  }

  String _iso(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _fmt(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

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

  Future<void> _downloadPdf() async {
    setState(() => _busy = true);
    try {
      final bytes = await ref.read(employerApiServiceProvider).statementPdf(
            dateFrom: _iso(_dateFrom),
            dateTo: _iso(_dateTo),
            currency: _currency,
          );
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/statement_${_iso(_dateFrom)}_${_iso(_dateTo)}.pdf');
      await file.writeAsBytes(bytes);
      if (!mounted) return;
      await Share.shareXFiles([XFile(file.path)], text: 'NEC Medical Statement');
    } on EmployerApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _emailStatement() async {
    setState(() => _busy = true);
    try {
      final message = await ref.read(employerApiServiceProvider).emailStatement(
            dateFrom: _iso(_dateFrom),
            dateTo: _iso(_dateTo),
            currency: _currency,
          );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } on EmployerApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statements = ref.watch(statementsProvider(_args));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Download PDF',
            onPressed: _busy ? null : _downloadPdf,
          ),
          IconButton(
            icon: const Icon(Icons.email_outlined),
            tooltip: 'Email statement',
            onPressed: _busy ? null : _emailStatement,
          ),
        ],
      ),
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
            child: statements.when(
              loading: () => AppShimmer(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: List.generate(
                    6,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ShimmerBox(width: double.infinity, height: 64, borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('$e', textAlign: TextAlign.center),
                ),
              ),
              data: (result) {
                if (result.rows.isEmpty) {
                  return const Center(child: Text('No statement entries for this period.'));
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Opening Balance', style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                                const SizedBox(height: 4),
                                Text(result.summary.openingBalance.toStringAsFixed(2),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.navy)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Closing Balance', style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                                const SizedBox(height: 4),
                                Text(result.summary.closingBalance.toStringAsFixed(2),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.tealDark)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...result.rows.map((row) => Container(
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
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: row.isBbf ? AppColors.iconBgLavender : AppColors.iconBgBlue,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(row.entryType,
                                              style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w700,
                                                  color: row.isBbf ? AppColors.iconLavender : AppColors.iconBlue)),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(_fmt(row.date), style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(row.description,
                                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (row.debit > 0)
                                    Text('-${row.debit.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.badgeRed)),
                                  if (row.credit > 0)
                                    Text('+${row.credit.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.tealDark)),
                                  const SizedBox(height: 2),
                                  Text('Bal: ${row.runningBalance.toStringAsFixed(2)}',
                                      style: TextStyle(fontSize: 10.5, color: colorScheme.onSurfaceVariant)),
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
}

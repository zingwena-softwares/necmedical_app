import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/app_colors.dart';
import '../../core/employer_api_client.dart';
import '../../models/employer/statement_models.dart';
import '../../providers/employer/employer_data_providers.dart';
import '../../providers/employer/employer_providers.dart';
import '../../widgets/employer/date_range_currency_filter.dart';
import '../../widgets/shimmer_box.dart';

final _money = NumberFormat('#,##0.00');

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
      if (bytes.isEmpty) {
        throw EmployerApiException('The server didn\'t return a PDF for this period. Please try again shortly.');
      }
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
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.navy, AppColors.navyLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (result.currencyLabel != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                              child: Text(result.currencyLabel!,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                            ),
                            const SizedBox(height: 12),
                          ],
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Opening Balance', style: TextStyle(fontSize: 11, color: Colors.white70)),
                                    const SizedBox(height: 4),
                                    Text(_money.format(result.summary.openingBalance),
                                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
                                  ],
                                ),
                              ),
                              Container(width: 1, height: 32, color: Colors.white24),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Closing Balance', style: TextStyle(fontSize: 11, color: Colors.white70)),
                                    const SizedBox(height: 4),
                                    Text(_money.format(result.summary.closingBalance),
                                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.teal)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            child: Row(
                              children: [
                                Expanded(flex: 5, child: Text('DATE / DESCRIPTION', style: _headerStyle(colorScheme))),
                                Expanded(flex: 3, child: Text('DEBIT', textAlign: TextAlign.right, style: _headerStyle(colorScheme))),
                                Expanded(flex: 3, child: Text('CREDIT', textAlign: TextAlign.right, style: _headerStyle(colorScheme))),
                                Expanded(flex: 3, child: Text('BALANCE', textAlign: TextAlign.right, style: _headerStyle(colorScheme))),
                              ],
                            ),
                          ),
                          for (int i = 0; i < result.rows.length; i++)
                            _StatementRowTile(row: result.rows[i], fmt: _fmt, striped: i.isOdd),
                        ],
                      ),
                    ),
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

TextStyle _headerStyle(ColorScheme colorScheme) => TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
      color: colorScheme.onSurfaceVariant,
    );

class _StatementRowTile extends StatelessWidget {
  final StatementRow row;
  final String Function(DateTime) fmt;
  final bool striped;

  const _StatementRowTile({required this.row, required this.fmt, required this.striped});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: striped ? colorScheme.surfaceContainerLowest : colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
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
                    Expanded(
                      child: Text(fmt(row.date),
                          style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(row.description,
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
                if (row.reference != null && row.reference!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text('Ref: ${row.reference}', style: TextStyle(fontSize: 10.5, color: colorScheme.onSurfaceVariant)),
                ],
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              row.debit > 0 ? _money.format(row.debit) : '—',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: row.debit > 0 ? FontWeight.w700 : FontWeight.w400,
                color: row.debit > 0 ? AppColors.badgeRed : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              row.credit > 0 ? _money.format(row.credit) : '—',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: row.credit > 0 ? FontWeight.w700 : FontWeight.w400,
                color: row.credit > 0 ? AppColors.tealDark : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              _money.format(row.runningBalance),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.navy),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../core/employer_field_style.dart';
import '../../providers/employer/employer_data_providers.dart';
import '../../widgets/shimmer_box.dart';
import 'return_detail_screen.dart';
import 'submit_return_screen.dart';

class ReturnsScreen extends ConsumerStatefulWidget {
  const ReturnsScreen({super.key});

  @override
  ConsumerState<ReturnsScreen> createState() => _ReturnsScreenState();
}

class _ReturnsScreenState extends ConsumerState<ReturnsScreen> {
  int _year = DateTime.now().year;
  int _currency = 2;

  YearCurrency get _args => (year: _year, currency: _currency);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final returns = ref.watch(returnsProvider(_args));

    return Scaffold(
      appBar: AppBar(title: const Text('Returns')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.navy,
        onPressed: () async {
          final submitted = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const SubmitReturnScreen()),
          );
          if (submitted == true) ref.invalidate(returnsProvider(_args));
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Submit Return'),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _year,
                    isExpanded: true,
                    decoration: employerFieldDecoration(context, label: 'Year'),
                    items: [for (int y = DateTime.now().year; y >= DateTime.now().year - 5; y--) DropdownMenuItem(value: y, child: Text('$y'))],
                    onChanged: (v) => setState(() => _year = v ?? _year),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _currency,
                    isExpanded: true,
                    decoration: employerFieldDecoration(context, label: 'Currency'),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Currency 1')),
                      DropdownMenuItem(value: 2, child: Text('Currency 2')),
                    ],
                    onChanged: (v) => setState(() => _currency = v ?? 2),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: returns.when(
              loading: () => AppShimmer(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: List.generate(
                    5,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ShimmerBox(width: double.infinity, height: 76, borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
              error: (e, _) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('$e'))),
              data: (result) {
                if (result.rows.isEmpty) {
                  return const Center(child: Text('No returns submitted for this year.'));
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                  children: result.rows.map((r) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Material(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReturnDetailScreen(rsId: r.id))),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                            ),
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${r.monthName} ${r.year}',
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
                                      const SizedBox(height: 3),
                                      Text('${r.totalEmployees} employees · Submitted ${r.submissionDate.day}/${r.submissionDate.month}/${r.submissionDate.year}',
                                          style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                                    ],
                                  ),
                                ),
                                Text(r.grandTotal.toStringAsFixed(2),
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.navy)),
                                const SizedBox(width: 6),
                                Icon(Icons.chevron_right_rounded, size: 18, color: colorScheme.onSurfaceVariant),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

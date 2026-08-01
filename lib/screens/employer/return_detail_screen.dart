import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../providers/employer/employer_data_providers.dart';
import '../../widgets/shimmer_box.dart';

class ReturnDetailScreen extends ConsumerWidget {
  final int rsId;
  const ReturnDetailScreen({super.key, required this.rsId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final detail = ref.watch(returnDetailProvider(rsId));

    return Scaffold(
      appBar: AppBar(title: const Text('Return Detail')),
      body: detail.when(
        loading: () => AppShimmer(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: List.generate(
              6,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ShimmerBox(width: double.infinity, height: 56, borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
        error: (e, _) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('$e'))),
        data: (result) {
          final header = result.header;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.navy, AppColors.navyLight]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${header.monthName} ${header.year}',
                        style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('${header.totalEmployees} employees · Submitted ${header.submissionDate.day}/${header.submissionDate.month}/${header.submissionDate.year}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _statTile('Employee', header.employeeContributionTotal),
                        ),
                        Expanded(
                          child: _statTile('Employer', header.employerContributionTotal),
                        ),
                        Expanded(
                          child: _statTile('Total', header.grandTotal),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Employees', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
              const SizedBox(height: 10),
              ...result.items.map((item) => Container(
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
                              Text(item.fullName, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
                              const SizedBox(height: 3),
                              Text('${item.employeeId} · Grade ${item.grade}',
                                  style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                              if (item.remarks.isNotEmpty && item.remarks.toLowerCase() != 'ok') ...[
                                const SizedBox(height: 4),
                                Text(item.remarks, style: const TextStyle(fontSize: 10.5, color: AppColors.badgeRed)),
                              ],
                            ],
                          ),
                        ),
                        Text(item.grandTotal.toStringAsFixed(2),
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: colorScheme.onSurface)),
                      ],
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }

  Widget _statTile(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value.toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

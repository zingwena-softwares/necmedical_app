import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../core/app_icon.dart';
import '../models/wp_content_item.dart';
import '../providers/wordpress_providers.dart';
import '../widgets/skeleton_loaders.dart';
import 'notice_detail_screen.dart';
import 'search_screen.dart';

class NoticesScreen extends ConsumerWidget {
  const NoticesScreen({super.key});

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notices = ref.watch(noticesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(noticesProvider.future),
        child: notices.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(16),
            children: const [NoticeCardSkeleton(), NoticeCardSkeleton(), NoticeCardSkeleton()],
          ),
          error: (error, _) => _ErrorView(
            message: '$error',
            onRetry: () => ref.invalidate(noticesProvider),
          ),
          data: (items) {
            if (items.isEmpty) {
              return const Center(child: Text('No notices right now.'));
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: items.map((item) => _NoticeCard(item: item)).toList(),
            );
          },
        ),
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final WpContentItem item;
  const _NoticeCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final d = item.date;
    final dateStr = '${d.day} ${NoticesScreen._months[d.month - 1]} ${d.year}';

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NoticeDetailScreen(item: item))),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(color: AppColors.iconBgTeal, shape: BoxShape.circle),
                child: const Center(child: AppAssetIcon('assets/icons/notice_icon.png', size: 19, color: AppColors.iconTeal)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
                    const SizedBox(height: 4),
                    Text(dateStr, style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 6),
                    Text(
                      item.excerpt,
                      style: TextStyle(fontSize: 12, height: 1.4, color: colorScheme.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off, size: 40, color: Colors.grey),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(message, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

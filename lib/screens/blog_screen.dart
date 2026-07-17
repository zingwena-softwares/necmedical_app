import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/wp_content_item.dart';
import '../providers/wordpress_providers.dart';
import '../widgets/skeleton_loaders.dart';
import 'blog_detail_screen.dart';
import 'search_screen.dart';

class BlogScreen extends ConsumerWidget {
  const BlogScreen({super.key});

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(blogPostsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(blogPostsProvider.future),
        child: posts.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              BlogFeaturedSkeleton(),
              SizedBox(height: 22),
              BlogRowSkeleton(),
              BlogRowSkeleton(),
              BlogRowSkeleton(),
            ],
          ),
          error: (error, _) => Center(child: Text('Error: $error')),
          data: (posts) {
            if (posts.isEmpty) {
              return const Center(child: Text('No blog posts yet.'));
            }
            final featured = posts.first;
            final recent = posts.skip(1).toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Featured Article', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
                const SizedBox(height: 10),
                _FeaturedCard(item: featured),
                if (recent.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  Text('Recent Articles', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
                  const SizedBox(height: 10),
                  ...recent.map((p) => _RecentRow(item: p)),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final WpContentItem item;
  const _FeaturedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final d = item.date;
    final dateStr = '${d.day} ${BlogScreen._months[d.month - 1]} ${d.year}';

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BlogDetailScreen(item: item))),
        child: Container(
          decoration: BoxDecoration(border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.featuredImageUrl != null)
                SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: item.featuredImageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: colorScheme.surfaceContainerHighest),
                    errorWidget: (_, __, ___) => Container(color: colorScheme.surfaceContainerHighest),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: colorScheme.onSurface),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text(dateStr, style: TextStyle(fontSize: 11.5, color: colorScheme.onSurfaceVariant)),
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

class _RecentRow extends StatelessWidget {
  final WpContentItem item;
  const _RecentRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final d = item.date;
    final dateStr = '${d.day} ${BlogScreen._months[d.month - 1]} ${d.year}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BlogDetailScreen(item: item))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 68,
                height: 68,
                child: item.featuredImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: item.featuredImageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: colorScheme.surfaceContainerHighest),
                        errorWidget: (_, __, ___) => Container(color: colorScheme.surfaceContainerHighest),
                      )
                    : Container(color: colorScheme.surfaceContainerHighest),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colorScheme.onSurface),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(dateStr, style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 18, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

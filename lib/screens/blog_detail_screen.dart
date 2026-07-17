import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/app_colors.dart';
import '../models/wp_content_item.dart';
import '../providers/wordpress_providers.dart';

class BlogDetailScreen extends ConsumerWidget {
  final WpContentItem item;
  const BlogDetailScreen({super.key, required this.item});

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final d = item.date;
    final dateStr = '${d.day} ${_months[d.month - 1]} ${d.year}';
    final related = ref.watch(blogPostsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Blog')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.featuredImageUrl != null)
              SizedBox(
                height: 200,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: item.featuredImageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: colorScheme.surfaceContainerHighest),
                  errorWidget: (_, __, ___) => Container(color: colorScheme.surfaceContainerHighest),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.categories.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.iconBgTeal, borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        item.categories.first.toUpperCase(),
                        style: const TextStyle(color: AppColors.tealDark, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.6),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(item.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, height: 1.3)),
                  const SizedBox(height: 6),
                  Text('$dateStr  ·  NEC Medical', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 16),
                  Html(data: item.htmlContent),
                  if (item.categories.length > 1) ...[
                    const SizedBox(height: 16),
                    Text('Tags', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: item.categories
                          .map((c) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(c, style: TextStyle(fontSize: 11, color: colorScheme.onSurface)),
                              ))
                          .toList(),
                    ),
                  ],
                  related.whenOrNull(
                        data: (posts) {
                          final others = posts.where((p) => p.id != item.id).take(3).toList();
                          if (others.isEmpty) return null;
                          return Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Related Articles',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
                                const SizedBox(height: 10),
                                ...others.map((p) => _RelatedRow(item: p)),
                              ],
                            ),
                          );
                        },
                      ) ??
                      const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RelatedRow extends StatelessWidget {
  final WpContentItem item;
  const _RelatedRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => BlogDetailScreen(item: item))),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 56,
                height: 56,
                child: item.featuredImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: item.featuredImageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(color: colorScheme.surfaceContainerHighest),
                      )
                    : Container(color: colorScheme.surfaceContainerHighest),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(item.title,
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

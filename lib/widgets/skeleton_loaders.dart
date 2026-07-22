import 'package:flutter/material.dart';
import 'shimmer_box.dart';

/// Mirrors the shape of a notice/office/info row card: leading icon circle
/// + title/subtitle bars. Used by Notices, Latest Notice, Search.
class NoticeCardSkeleton extends StatelessWidget {
  const NoticeCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerBox.circle(size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: double.infinity, height: 14),
                  const SizedBox(height: 8),
                  const ShimmerBox(width: 80, height: 10),
                  const SizedBox(height: 8),
                  ShimmerBox(width: MediaQuery.sizeOf(context).width * 0.5, height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mirrors the Blog "Featured Article" card: image block + title/date bars.
class BlogFeaturedSkeleton extends StatelessWidget {
  const BlogFeaturedSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerBox(height: 160, borderRadius: BorderRadius.zero),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(width: double.infinity, height: 15),
                  const SizedBox(height: 8),
                  ShimmerBox(width: MediaQuery.sizeOf(context).width * 0.4, height: 11),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mirrors a Blog "Recent Articles" row: thumbnail + title/date bars.
class BlogRowSkeleton extends StatelessWidget {
  const BlogRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerBox(width: 68, height: 68, borderRadius: BorderRadius.all(Radius.circular(10))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(width: double.infinity, height: 13),
                  const SizedBox(height: 6),
                  const ShimmerBox(width: double.infinity, height: 13),
                  const SizedBox(height: 8),
                  const ShimmerBox(width: 70, height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mirrors the Home "Latest Insights" horizontal card: thumbnail + 2 title
/// lines + date.
class InsightCardSkeleton extends StatelessWidget {
  const InsightCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerBox(width: 150, height: 80, borderRadius: BorderRadius.all(Radius.circular(12))),
            const SizedBox(height: 6),
            const ShimmerBox(width: double.infinity, height: 11),
            const SizedBox(height: 4),
            const ShimmerBox(width: 100, height: 11),
            const SizedBox(height: 4),
            const ShimmerBox(width: 60, height: 9),
          ],
        ),
      ),
    );
  }
}

/// Grid of square placeholders, matching the Gallery grid.
class GalleryGridSkeleton extends StatelessWidget {
  const GalleryGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 8,
        itemBuilder: (context, index) => const ShimmerBox(height: double.infinity, borderRadius: BorderRadius.all(Radius.circular(8))),
      ),
    );
  }
}

/// Mirrors a Contact office card / About info card: heading + a few text lines.
class InfoCardSkeleton extends StatelessWidget {
  final int lines;
  const InfoCardSkeleton({super.key, this.lines = 3});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerBox(width: 120, height: 14),
            const SizedBox(height: 12),
            for (int i = 0; i < lines; i++) ...[
              ShimmerBox(width: i.isEven ? double.infinity : 180, height: 11),
              if (i != lines - 1) const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

/// A generic single-line list row skeleton (Search results, etc).
class RowSkeleton extends StatelessWidget {
  const RowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            const ShimmerBox(width: 18, height: 18, borderRadius: BorderRadius.all(Radius.circular(4))),
            const SizedBox(width: 12),
            Expanded(child: ShimmerBox(width: double.infinity, height: 14)),
          ],
        ),
      ),
    );
  }
}

/// Compact shimmer content for a blocking modal dialog shown during a quick
/// fetch-then-navigate (e.g. tapping a search result or a "More" menu page).
class ShimmerDialogLoader extends StatelessWidget {
  const ShimmerDialogLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: AppShimmer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              ShimmerBox(width: 140, height: 14),
              SizedBox(height: 10),
              ShimmerBox(width: double.infinity, height: 10),
              SizedBox(height: 8),
              ShimmerBox(width: 220, height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder for an in-content <img> while it loads over the network —
/// used inside notice/content HTML bodies (ResponsiveHtml) instead of a bare
/// spinner.
class ContentImageSkeleton extends StatelessWidget {
  final double width;
  final double height;
  const ContentImageSkeleton({super.key, required this.width, this.height = 180});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ShimmerBox(width: width, height: height, borderRadius: BorderRadius.circular(10)),
    );
  }
}

/// Generic full-page skeleton for the Employer Portal / Self Service WebView
/// screens while the external page is loading — mimics a simple page layout
/// (header bar + content blocks) rather than a bare spinner.
class WebPageSkeleton extends StatelessWidget {
  const WebPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerBox(width: double.infinity, height: 44, borderRadius: BorderRadius.all(Radius.circular(10))),
            const SizedBox(height: 20),
            const ShimmerBox(width: 160, height: 16),
            const SizedBox(height: 16),
            const ShimmerBox(width: double.infinity, height: 100, borderRadius: BorderRadius.all(Radius.circular(10))),
            const SizedBox(height: 20),
            const ShimmerBox(width: double.infinity, height: 14),
            const SizedBox(height: 10),
            const ShimmerBox(width: double.infinity, height: 14),
            const SizedBox(height: 10),
            const ShimmerBox(width: 220, height: 14),
          ],
        ),
      ),
    );
  }
}

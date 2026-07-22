import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../core/document_downloader.dart';
import '../models/document_list_content.dart';
import '../models/downloadable_document.dart';
import '../models/wp_content_item.dart';
import '../widgets/shimmer_box.dart';

/// Generic "intro + list of downloadable documents" screen — used for both
/// Registration and CBA, which share the same WordPress content shape.
class DocumentListScreen extends ConsumerWidget {
  final String appBarTitle;
  final String badgeLabel;
  final AutoDisposeFutureProvider<WpContentItem?> pageProvider;
  final AutoDisposeFutureProvider<DocumentListContent?> contentProvider;

  const DocumentListScreen({
    super.key,
    required this.appBarTitle,
    required this.badgeLabel,
    required this.pageProvider,
    required this.contentProvider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentProvider);
    final rawPage = ref.watch(pageProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.navy, AppColors.navyLight]),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                badgeLabel,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 1.2),
              ),
            ),
            const SizedBox(height: 20),
            content.when(
              loading: () => const _DocumentListSkeleton(),
              error: (_, __) => _fallback(rawPage),
              data: (data) {
                if (data == null || data.documents.isEmpty) return _fallback(rawPage);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (data.intro.isNotEmpty)
                      Text(
                        data.intro,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, height: 1.5, color: colorScheme.onSurfaceVariant),
                      ),
                    const SizedBox(height: 20),
                    ...data.documents.map((d) => _DocumentCard(document: d)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallback(AsyncValue rawPage) {
    return rawPage.when(
      loading: () => const _DocumentListSkeleton(),
      error: (e, __) => Text('$e'),
      data: (page) =>
          page == null ? const Text('This information is unavailable right now.') : Html(data: page.htmlContent),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final DownloadableDocument document;
  const _DocumentCard({required this.document});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Text(
            document.title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colorScheme.onSurface),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => downloadDocument(context, url: document.downloadUrl, title: document.title),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              icon: const Icon(Icons.file_download_outlined, size: 18),
              label: const Text('DOWNLOAD', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5)),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentListSkeleton extends StatelessWidget {
  const _DocumentListSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        children: List.generate(
          3,
          (i) => Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                const ShimmerBox(width: 200, height: 16),
                const SizedBox(height: 16),
                ShimmerBox(width: double.infinity, height: 44, borderRadius: BorderRadius.circular(12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

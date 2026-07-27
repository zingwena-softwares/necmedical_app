import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_colors.dart';
import '../providers/wordpress_providers.dart';
import '../widgets/skeleton_loaders.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aboutContent = ref.watch(aboutContentProvider);
    final rawPage = ref.watch(aboutPageProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('About NEC Medical')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.navy, AppColors.navyLight]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Image.asset('assets/images/nec_logo.png', fit: BoxFit.contain),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Who We Are', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                        SizedBox(height: 4),
                        Text(
                          'The National Employment Council for the Medical and Allied Industry promotes fair labour practices and supports the growth of a sustainable industry.',
                          style: TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            aboutContent.when(
              loading: () => const Column(
                children: [InfoCardSkeleton(), InfoCardSkeleton(lines: 2), InfoCardSkeleton(lines: 4)],
              ),
              error: (_, __) => _fallback(rawPage),
              data: (content) {
                if (content == null || !content.hasStructuredContent) return _fallback(rawPage);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (content.intro.isNotEmpty) ...[
                      Text(content.intro, style: TextStyle(fontSize: 13, height: 1.5, color: colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 16),
                    ],
                    if (content.mission != null)
                      _InfoCard(icon: Icons.track_changes_rounded, title: 'Our Mission', body: content.mission!),
                    if (content.vision != null)
                      _InfoCard(icon: Icons.visibility_outlined, title: 'Our Vision', body: content.vision!),
                    if (content.values.isNotEmpty)
                      _ValuesCard(values: content.values),
                    if (content.backgroundText != null) ...[
                      const SizedBox(height: 8),
                      Text('Background', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
                      const SizedBox(height: 8),
                      Text(content.backgroundText!, style: TextStyle(fontSize: 12.5, height: 1.5, color: colorScheme.onSurfaceVariant)),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => launchUrl(Uri.parse('https://necmedical.org.zw/about/'), mode: LaunchMode.externalApplication),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Learn More on Our Website'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallback(AsyncValue rawPage) {
    return rawPage.when(
      loading: () => const Column(
        children: [InfoCardSkeleton(), InfoCardSkeleton()],
      ),
      error: (e, __) => Text('$e'),
      data: (page) => page == null ? const Text('About page is unavailable right now.') : Html(data: page.htmlContent),
    );
  }
}

class _ValuesCard extends StatelessWidget {
  final List<String> values;
  const _ValuesCard({required this.values});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(color: AppColors.iconBgTeal, shape: BoxShape.circle),
            child: const Icon(Icons.diamond_outlined, size: 18, color: AppColors.iconTeal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Our Values', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
                const SizedBox(height: 6),
                for (final value in values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('•  ', style: TextStyle(fontSize: 12, height: 1.4, color: colorScheme.onSurfaceVariant)),
                        Expanded(
                          child: Text(value, style: TextStyle(fontSize: 12, height: 1.4, color: colorScheme.onSurfaceVariant)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _InfoCard({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(color: AppColors.iconBgTeal, shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: AppColors.iconTeal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
                const SizedBox(height: 4),
                Text(body, style: TextStyle(fontSize: 12, height: 1.4, color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

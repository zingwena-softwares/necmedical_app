import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/wp_content_item.dart';
import '../services/page_header_parser.dart';
import '../widgets/responsive_html.dart';

class ContentDetailScreen extends StatelessWidget {
  final WpContentItem item;

  /// When set, shows a styled pill badge (matching Registration/CBA) instead
  /// of the page's own raw <h1>/<h4> heading markup.
  final String? badgeLabel;

  const ContentDetailScreen({super.key, required this.item, this.badgeLabel});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = badgeLabel;

    if (label == null) {
      return Scaffold(
        appBar: AppBar(title: Text(item.title)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ResponsiveHtml(data: item.htmlContent),
        ),
      );
    }

    final body = parsePageBody(item.htmlContent);
    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
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
                label,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 1.2),
              ),
            ),
            const SizedBox(height: 20),
            if (body.intro.isNotEmpty)
              Text(
                body.intro,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, height: 1.5, color: colorScheme.onSurfaceVariant),
              ),
            const SizedBox(height: 20),
            ResponsiveHtml(data: body.bodyHtml),
          ],
        ),
      ),
    );
  }
}

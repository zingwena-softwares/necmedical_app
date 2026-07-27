import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_icon.dart';
import '../models/wp_content_item.dart';
import '../widgets/responsive_html.dart';

class NoticeDetailScreen extends StatelessWidget {
  final WpContentItem item;
  const NoticeDetailScreen({super.key, required this.item});

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final d = item.date;
    final dateStr = '${d.day} ${_months[d.month - 1]} ${d.year}';

    return Scaffold(
      appBar: AppBar(title: const Text('Notice Detail')),
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
              child: const Text(
                'NOTICE',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 1.2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppAssetIcon('assets/icons/calendar_icon.png', size: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 5),
                Text(dateStr, style: TextStyle(fontSize: 12.5, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 20),
            ResponsiveHtml(data: item.htmlContent),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../core/app_colors.dart';
import '../core/app_icon.dart';
import '../models/wp_content_item.dart';

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.iconBgTeal, borderRadius: BorderRadius.circular(6)),
              child: const Text(
                'NOTICE',
                style: TextStyle(color: AppColors.tealDark, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.6),
              ),
            ),
            const SizedBox(height: 10),
            Text(item.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Row(
              children: [
                AppAssetIcon('assets/icons/calendar_icon.png', size: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 5),
                Text(dateStr, style: TextStyle(fontSize: 12.5, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 16),
            Html(data: item.htmlContent),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/wp_content_item.dart';
import '../widgets/responsive_html.dart';

class ContentDetailScreen extends StatelessWidget {
  final WpContentItem item;

  const ContentDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ResponsiveHtml(data: item.htmlContent),
      ),
    );
  }
}

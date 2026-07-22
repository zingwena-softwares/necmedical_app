import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'skeleton_loaders.dart';

/// Renders WordPress HTML content with images scaled to fit the available
/// width instead of the fixed pixel width/height WordPress embeds in <img>
/// attributes (which otherwise overflow the screen on mobile).
class ResponsiveHtml extends StatelessWidget {
  final String data;
  const ResponsiveHtml({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Html(
          data: data,
          extensions: [
            ImageExtension(
              builder: (extContext) {
                final src = extContext.attributes['src'];
                if (src == null || src.isEmpty) {
                  return const SizedBox.shrink();
                }
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    src,
                    width: constraints.maxWidth,
                    fit: BoxFit.contain,
                    loadingBuilder: (ctx, child, progress) {
                      if (progress == null) return child;
                      return ContentImageSkeleton(width: constraints.maxWidth);
                    },
                    errorBuilder: (ctx, error, stackTrace) => const SizedBox.shrink(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

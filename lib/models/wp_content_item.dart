class WpContentItem {
  final int id;
  final String title;
  final String htmlContent;
  final String excerpt;
  final DateTime date;
  final int featuredMediaId;
  final List<String> categories; // real WP category/tag names, via ?_embed
  String? featuredImageUrl; // filled in after a separate media lookup

  WpContentItem({
    required this.id,
    required this.title,
    required this.htmlContent,
    required this.excerpt,
    required this.date,
    required this.featuredMediaId,
    this.categories = const [],
    this.featuredImageUrl,
  });

  factory WpContentItem.fromJson(Map<String, dynamic> json) {
    final categories = <String>[];
    final embedded = json['_embedded'] as Map<String, dynamic>?;
    final termGroups = embedded?['wp:term'] as List<dynamic>?;
    if (termGroups != null) {
      for (final group in termGroups) {
        if (group is! List) continue;
        for (final term in group) {
          if (term is Map<String, dynamic> && term['name'] is String) {
            categories.add(term['name'] as String);
          }
        }
      }
    }

    return WpContentItem(
      id: json['id'] ?? 0,
      title: _stripHtml(json['title']?['rendered'] ?? ''),
      htmlContent: json['content']?['rendered'] ?? '',
      excerpt: _stripHtml(json['excerpt']?['rendered'] ?? ''),
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      featuredMediaId: json['featured_media'] ?? 0,
      categories: categories,
    );
  }

  static String _stripHtml(String htmlText) {
    return htmlText.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }
}

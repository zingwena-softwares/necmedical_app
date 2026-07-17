enum SearchResultType { post, page, other }

class SearchResult {
  final int id;
  final String title;
  final SearchResultType type;

  const SearchResult({required this.id, required this.title, required this.type});

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id'] ?? 0,
      title: (json['title'] ?? '').toString(),
      type: switch (json['subtype'] ?? json['type']) {
        'post' => SearchResultType.post,
        'page' => SearchResultType.page,
        _ => SearchResultType.other,
      },
    );
  }
}

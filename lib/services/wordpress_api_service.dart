import '../core/api_client.dart';
import '../core/constants.dart';
import '../models/gallery_image.dart';
import '../models/search_result.dart';
import '../models/wp_content_item.dart';

class WordpressApiService {
  WordpressApiService({ApiClient? client}) : _client = client ?? ApiClient(ApiConstants.wpBaseUrl);

  final ApiClient _client;

  /// Fetch blog posts (Blog section on website). `_embed` pulls in real
  /// category/tag names so we don't have to fabricate them client-side.
  Future<List<WpContentItem>> fetchPosts({int perPage = 10, int page = 1}) {
    return _fetchList('/posts', query: {'per_page': perPage, 'page': page, '_embed': true});
  }

  /// Fetch a single post by id, with embedded categories.
  Future<WpContentItem?> fetchPostById(int id) async {
    final data = await _client.getJson('/posts/$id', query: {'_embed': true});
    if (data == null) return null;
    final item = WpContentItem.fromJson(data as Map<String, dynamic>);
    if (item.featuredMediaId != 0) {
      item.featuredImageUrl = await fetchMediaUrl(item.featuredMediaId);
    }
    return item;
  }

  /// Fetch pages by slug — used for Notices, CBA, About, Registration, Projects.
  /// Example: fetchPageBySlug('notices')
  Future<List<WpContentItem>> fetchPageBySlug(String slug) {
    return _fetchList('/pages', query: {'slug': slug});
  }

  /// Fetch all top-level pages (useful for building an "About/Info" nav list)
  Future<List<WpContentItem>> fetchAllPages({int perPage = 20}) {
    return _fetchList('/pages', query: {'per_page': perPage});
  }

  /// Fetch gallery images. WP does return title/caption fields per image,
  /// but on this site they're just raw filenames, not real captions — we
  /// surface them as-is rather than fabricating nicer text.
  Future<List<GalleryImage>> fetchGalleryImages({int perPage = 30}) async {
    final data = await _client.getJson('/media', query: {'media_type': 'image', 'per_page': perPage});
    return (data as List)
        .map((item) {
          final url = item['source_url'] as String?;
          if (url == null) return null;
          final title = (item['title']?['rendered'] as String?)?.trim() ?? '';
          return GalleryImage(url: url, title: title);
        })
        .whereType<GalleryImage>()
        .toList();
  }

  /// Fetch a single featured image URL by media ID (used to hydrate WpContentItem)
  Future<String?> fetchMediaUrl(int mediaId) async {
    if (mediaId == 0) return null;
    final data = await _client.getJson('/media/$mediaId');
    return data['source_url'] as String?;
  }

  /// Real cross-content search via WordPress's built-in /search endpoint
  /// (covers posts and pages).
  Future<List<SearchResult>> search(String query) async {
    if (query.trim().isEmpty) return [];
    final data = await _client.getJson('/search', query: {'search': query, 'per_page': 20});
    return (data as List).map((json) => SearchResult.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<List<WpContentItem>> _fetchList(String path, {Map<String, dynamic>? query}) async {
    final data = await _client.getJson(path, query: query);
    final items = (data as List)
        .map((json) => WpContentItem.fromJson(json as Map<String, dynamic>))
        .toList();

    // Hydrate featured images (best-effort, ignore failures)
    for (final item in items) {
      if (item.featuredMediaId != 0) {
        item.featuredImageUrl = await fetchMediaUrl(item.featuredMediaId);
      }
    }
    return items;
  }
}

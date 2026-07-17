import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/about_content.dart';
import '../models/gallery_image.dart';
import '../models/office_contact.dart';
import '../models/search_result.dart';
import '../models/wp_content_item.dart';
import '../services/about_page_parser.dart';
import '../services/contact_page_parser.dart';
import '../services/wordpress_api_service.dart';

final wordpressApiServiceProvider = Provider<WordpressApiService>((ref) {
  return WordpressApiService();
});

final noticesProvider = FutureProvider.autoDispose<List<WpContentItem>>((ref) {
  return ref.watch(wordpressApiServiceProvider).fetchPageBySlug('notices');
});

final blogPostsProvider = FutureProvider.autoDispose<List<WpContentItem>>((ref) {
  return ref.watch(wordpressApiServiceProvider).fetchPosts();
});

final galleryImagesProvider = FutureProvider.autoDispose<List<GalleryImage>>((ref) {
  return ref.watch(wordpressApiServiceProvider).fetchGalleryImages();
});

final contactPageProvider = FutureProvider.autoDispose<WpContentItem?>((ref) async {
  final items = await ref.watch(wordpressApiServiceProvider).fetchPageBySlug('contact');
  return items.isNotEmpty ? items.first : null;
});

final aboutPageProvider = FutureProvider.autoDispose<WpContentItem?>((ref) async {
  final items = await ref.watch(wordpressApiServiceProvider).fetchPageBySlug('about');
  return items.isNotEmpty ? items.first : null;
});

/// Structured per-office contact details, parsed from the real Contact page.
final officeContactsProvider = FutureProvider.autoDispose<List<OfficeContact>>((ref) async {
  final page = await ref.watch(contactPageProvider.future);
  if (page == null) return [];
  return parseOfficeContacts(page.htmlContent);
});

/// Structured Vision/Mission/Values/Background, parsed from the real About page.
final aboutContentProvider = FutureProvider.autoDispose<AboutContent?>((ref) async {
  final page = await ref.watch(aboutPageProvider.future);
  if (page == null) return null;
  return parseAboutContent(page.htmlContent);
});

final searchResultsProvider = FutureProvider.autoDispose.family<List<SearchResult>, String>((ref, query) {
  return ref.watch(wordpressApiServiceProvider).search(query);
});

final postByIdProvider = FutureProvider.autoDispose.family<WpContentItem?, int>((ref, id) {
  return ref.watch(wordpressApiServiceProvider).fetchPostById(id);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/about_content.dart';
import '../models/document_list_content.dart';
import '../models/gallery_image.dart';
import '../models/office_contact.dart';
import '../models/search_result.dart';
import '../models/wp_content_item.dart';
import '../services/about_page_parser.dart';
import '../services/appointment_service.dart';
import '../services/contact_page_parser.dart';
import '../services/document_list_parser.dart';
import '../services/gallery_page_parser.dart';
import '../services/wordpress_api_service.dart';

final wordpressApiServiceProvider = Provider<WordpressApiService>((ref) {
  return WordpressApiService();
});

final appointmentServiceProvider = Provider<AppointmentService>((ref) {
  return AppointmentService();
});

final noticesProvider = FutureProvider.autoDispose<List<WpContentItem>>((ref) {
  return ref.watch(wordpressApiServiceProvider).fetchPageBySlug('notices');
});

final blogPostsProvider = FutureProvider.autoDispose<List<WpContentItem>>((ref) {
  return ref.watch(wordpressApiServiceProvider).fetchPosts();
});

/// Photos from the real Gallery page (`necmedical.org.zw/gallery`), in the
/// same order and with the same captions shown on the website. Falls back to
/// the raw media library if the page has no parseable images (e.g. the
/// Elementor template changed).
final galleryImagesProvider = FutureProvider.autoDispose<List<GalleryImage>>((ref) async {
  final service = ref.watch(wordpressApiServiceProvider);
  final pages = await service.fetchPageBySlug('gallery');
  if (pages.isNotEmpty) {
    final images = parseGalleryImages(pages.first.htmlContent);
    if (images.isNotEmpty) return images;
  }
  return service.fetchGalleryImages();
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

final registrationPageProvider = FutureProvider.autoDispose<WpContentItem?>((ref) async {
  final items = await ref.watch(wordpressApiServiceProvider).fetchPageBySlug('registration');
  return items.isNotEmpty ? items.first : null;
});

/// Structured intro + downloadable forms, parsed from the real Registration page.
final registrationContentProvider = FutureProvider.autoDispose<DocumentListContent?>((ref) async {
  final page = await ref.watch(registrationPageProvider.future);
  if (page == null) return null;
  return parseDocumentList(page.htmlContent);
});

final cbaPageProvider = FutureProvider.autoDispose<WpContentItem?>((ref) async {
  final items = await ref.watch(wordpressApiServiceProvider).fetchPageBySlug('cba');
  return items.isNotEmpty ? items.first : null;
});

/// Structured intro + downloadable CBA documents, parsed from the real CBA page.
final cbaContentProvider = FutureProvider.autoDispose<DocumentListContent?>((ref) async {
  final page = await ref.watch(cbaPageProvider.future);
  if (page == null) return null;
  return parseDocumentList(page.htmlContent);
});

final searchResultsProvider = FutureProvider.autoDispose.family<List<SearchResult>, String>((ref, query) {
  return ref.watch(wordpressApiServiceProvider).search(query);
});

final postByIdProvider = FutureProvider.autoDispose.family<WpContentItem?, int>((ref, id) {
  return ref.watch(wordpressApiServiceProvider).fetchPostById(id);
});

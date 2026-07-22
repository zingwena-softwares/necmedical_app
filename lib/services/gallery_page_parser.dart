import 'package:html/parser.dart' as html_parser;
import '../models/gallery_image.dart';

/// Parses the real NEC Medical Gallery page (Elementor markup) into an
/// ordered list of photos with their captions.
///
/// The page interleaves `.elementor-widget-image` blocks with one or two
/// `.elementor-widget-text-editor` paragraphs describing the photo right
/// after it (e.g. "Some of the CBA Committee Members – posing for..."). Not
/// every photo has a caption — later sections are a plain grid with none.
///
/// Markup-dependent — if the site's page template changes, this may come
/// back empty, in which case callers should fall back to the media-library
/// based gallery.
List<GalleryImage> parseGalleryImages(String htmlContent) {
  final document = html_parser.parse(htmlContent);
  final nodes = document.querySelectorAll(
    '.elementor-widget-image img, .elementor-widget-text-editor p',
  );

  final images = <GalleryImage>[];
  String? pendingUrl;
  final captionParts = <String>[];

  void flush() {
    if (pendingUrl != null) {
      images.add(GalleryImage(url: pendingUrl!, title: captionParts.join(' — ')));
    }
    pendingUrl = null;
    captionParts.clear();
  }

  for (final node in nodes) {
    if (node.localName == 'img') {
      flush();
      pendingUrl = node.attributes['src'];
    } else if (pendingUrl != null) {
      final text = node.text.trim();
      if (text.isNotEmpty) captionParts.add(text);
    }
  }
  flush();

  return images;
}

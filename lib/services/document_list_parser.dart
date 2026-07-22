import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import '../models/document_list_content.dart';
import '../models/downloadable_document.dart';

/// Parses a NEC Medical WP page (Elementor markup) that lists downloadable
/// documents — used for both Registration and CBA, which use slightly
/// different patterns:
///  - Registration: each doc is an Elementor "button" widget whose visible
///    text is just "Download"; the real title is the text-editor widget
///    directly before it.
///  - CBA: each doc's anchor text IS the real title (e.g. "Collective
///    Bargaining Agreement (CBA) - June 2026"), some as buttons, some as
///    plain links inside headings (Statutory Instruments).
///
/// This handles both by using the anchor's own text when it looks like a
/// real title, and falling back to the preceding sibling paragraph when the
/// anchor text is just a generic "Download" label.
///
/// Markup-dependent — if the site's page template changes, this may come
/// back with an empty document list, in which case callers should fall back
/// to rendering the raw page content.
DocumentListContent parseDocumentList(String htmlContent) {
  final document = html_parser.parse(htmlContent);

  final intro = document.querySelector('.elementor-widget-text-editor p')?.text.trim() ?? '';

  final documents = <DownloadableDocument>[];
  for (final anchor in document.querySelectorAll('a[href]')) {
    final href = anchor.attributes['href'];
    if (href == null) continue;
    final lower = href.toLowerCase();
    if (!(lower.endsWith('.pdf') || lower.endsWith('.doc') || lower.endsWith('.docx'))) continue;

    final anchorText = anchor.text.trim();
    String? title = (anchorText.isNotEmpty && anchorText.toLowerCase() != 'download') ? anchorText : null;

    title ??= _titleFromPrecedingSibling(anchor);
    title ??= _titleFromUrl(href);

    documents.add(DownloadableDocument(title: title, downloadUrl: href));
  }

  return DocumentListContent(intro: intro, documents: documents);
}

String? _titleFromPrecedingSibling(Element anchor) {
  var widget = anchor;
  while (widget.parent != null && !widget.classes.contains('elementor-widget')) {
    widget = widget.parent!;
  }
  var sibling = widget.previousElementSibling;
  while (sibling != null) {
    final p = sibling.querySelector('p');
    if (p != null && p.text.trim().isNotEmpty) return p.text.trim();
    sibling = sibling.previousElementSibling;
  }
  return null;
}

String _titleFromUrl(String url) {
  final name = Uri.parse(url).pathSegments.isNotEmpty ? Uri.parse(url).pathSegments.last : url;
  final withoutExt = name.replaceAll(RegExp(r'\.(pdf|docx?)$', caseSensitive: false), '');
  return withoutExt.replaceAll(RegExp(r'[-_]+'), ' ').trim();
}

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

class ParsedPageBody {
  final String intro;
  final String bodyHtml;
  const ParsedPageBody({required this.intro, required this.bodyHtml});
}

/// Strips the redundant "<h1>Title</h1><h4>Subtitle</h4>" heading widgets
/// that these WP pages render at the top (we show our own styled badge
/// instead) and pulls out the first paragraph as an intro blurb, leaving the
/// remaining markup (images, etc.) to render as-is.
ParsedPageBody parsePageBody(String htmlContent) {
  final document = html_parser.parse(htmlContent);

  final introParagraph = document.querySelector('.elementor-widget-text-editor p');
  final intro = introParagraph?.text.trim() ?? '';

  for (final heading in document.querySelectorAll('.elementor-widget-heading').toList()) {
    heading.remove();
  }
  _widgetAncestor(introParagraph)?.remove();

  return ParsedPageBody(intro: intro, bodyHtml: document.body?.innerHtml ?? htmlContent);
}

Element? _widgetAncestor(Element? node) {
  var current = node;
  while (current != null && !current.classes.contains('elementor-widget')) {
    current = current.parent;
  }
  return current;
}

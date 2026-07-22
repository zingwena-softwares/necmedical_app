import 'package:html/parser.dart' as html_parser;
import '../models/about_content.dart';

/// Parses NEC Medical's About WP page (Elementor markup) into structured
/// Vision/Mission/Values/Background sections. Markup-dependent — if the
/// site's page template changes, structured fields may come back null,
/// in which case callers should fall back to rendering the raw page content.
AboutContent parseAboutContent(String htmlContent) {
  final document = html_parser.parse(htmlContent);

  final introParagraph = document.querySelector('.elementor-widget-text-editor p');
  final intro = introParagraph?.text.trim() ?? '';

  String? vision;
  String? mission;
  List<String> values = [];

  for (final box in document.querySelectorAll('.elementor-widget-icon-box')) {
    final label = box.querySelector('.elementor-icon-box-title')?.text.trim();
    final description = box.querySelector('.elementor-icon-box-description')?.text.trim();
    if (label == null) continue;

    if (label.toLowerCase() == 'vision' && description != null) {
      vision = description;
    } else if (label.toLowerCase() == 'mission' && description != null) {
      mission = description;
    } else if (label.toLowerCase() == 'values') {
      // The values list sits in a sibling text-editor widget as a <ul><li>.
      var sibling = box.parent?.nextElementSibling;
      while (sibling != null) {
        final listItems = sibling.querySelectorAll('li');
        if (listItems.isNotEmpty) {
          values = listItems.map((li) => li.text.trim()).where((v) => v.isNotEmpty).toList();
          break;
        }
        sibling = sibling.nextElementSibling;
      }
    }
  }

  String? backgroundText;
  for (final heading in document.querySelectorAll('h2.elementor-heading-title')) {
    if (heading.text.trim().toLowerCase() == 'background') {
      final next = heading.parent?.nextElementSibling;
      final paragraphs = next?.querySelectorAll('p') ?? [];
      if (paragraphs.isNotEmpty) {
        // Keep this to just 1-2 paragraphs — mobile users want the Vision/
        // Mission/Values and the "Learn More" link, not the full website copy.
        backgroundText = paragraphs.take(2).map((p) => p.text.trim()).join('\n\n');
      }
      break;
    }
  }

  return AboutContent(
    intro: intro,
    vision: vision,
    mission: mission,
    values: values,
    backgroundText: backgroundText,
  );
}

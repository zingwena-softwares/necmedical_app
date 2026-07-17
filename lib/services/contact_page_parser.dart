import 'package:html/parser.dart' as html_parser;
import '../models/office_contact.dart';

/// Parses NEC Medical's Contact WP page (Elementor markup) into structured
/// per-office entries. This is markup-dependent — if the site's page
/// template changes, this may return an empty list, in which case callers
/// should fall back to rendering the raw page content.
List<OfficeContact> parseOfficeContacts(String htmlContent) {
  final document = html_parser.parse(htmlContent);
  final offices = <OfficeContact>[];

  final headings = document.querySelectorAll('h3.elementor-heading-title');
  for (final heading in headings) {
    final city = heading.text.trim();
    if (city.isEmpty) continue;

    // The icon-list widget with contact details sits in the same container,
    // after this heading and the "Reach Us" sub-heading.
    var container = heading.parent;
    while (container != null && container.querySelector('ul.elementor-icon-list-items') == null) {
      container = container.parent;
    }
    final items = container?.querySelectorAll('.elementor-icon-list-text') ?? [];
    if (items.length < 3) continue;

    offices.add(OfficeContact(
      city: city,
      email: items[0].text.trim(),
      phone: items[1].text.trim(),
      address: items[2].text.trim(),
    ));
  }

  return offices;
}

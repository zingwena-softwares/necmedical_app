class AboutContent {
  final String intro;
  final String? vision;
  final String? mission;
  final List<String> values;
  final String? backgroundText;

  const AboutContent({
    required this.intro,
    this.vision,
    this.mission,
    this.values = const [],
    this.backgroundText,
  });

  bool get hasStructuredContent => vision != null || mission != null || values.isNotEmpty || backgroundText != null;
}

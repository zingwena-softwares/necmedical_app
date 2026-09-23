class LookupEmployer {
  final int id;
  final String tradeName;
  const LookupEmployer({required this.id, required this.tradeName});
  factory LookupEmployer.fromJson(Map<String, dynamic> json) =>
      LookupEmployer(id: json['id'] as int, tradeName: (json['trade_name'] as String?)?.trim() ?? '');
}

class NamedLookup {
  final int id;
  final String name;
  const NamedLookup({required this.id, required this.name});
  factory NamedLookup.fromJson(Map<String, dynamic> json) => NamedLookup(id: json['id'] as int, name: json['name'] as String);
}

/// Everything the case/report forms need in one call (`GET /lookups`).
class SelfServiceLookups {
  final List<LookupEmployer> employers;
  final List<NamedLookup> natureCases;
  final List<NamedLookup> sectors;
  final List<NamedLookup> districts;
  final List<NamedLookup> tradeUnions;
  final List<NamedLookup> occupations;
  final List<NamedLookup> grades;
  final List<String> reportPresets;

  const SelfServiceLookups({
    required this.employers,
    required this.natureCases,
    required this.sectors,
    required this.districts,
    required this.tradeUnions,
    required this.occupations,
    required this.grades,
    required this.reportPresets,
  });

  factory SelfServiceLookups.fromJson(Map<String, dynamic> json) {
    List<NamedLookup> named(String key) =>
        ((json[key] as List?) ?? []).map((e) => NamedLookup.fromJson(e as Map<String, dynamic>)).toList();
    return SelfServiceLookups(
      employers: ((json['employers'] as List?) ?? []).map((e) => LookupEmployer.fromJson(e as Map<String, dynamic>)).toList(),
      natureCases: named('nature_cases'),
      sectors: named('sectors'),
      districts: named('districts'),
      tradeUnions: named('trade_unions'),
      occupations: named('occupations'),
      grades: named('grades'),
      reportPresets: ((json['report_presets'] as List?) ?? []).map((e) => e.toString()).toList(),
    );
  }
}

String reportPresetLabel(String preset) {
  switch (preset) {
    case 'accident':
      return 'Workplace accident';
    case 'sexual_harassment':
      return 'Sexual harassment';
    case 'complaint':
      return 'General complaint';
    default:
      return preset;
  }
}

/// Incident categories. Persisted in Firestore using the enum `name` (the key).
enum IncidentCategory {
  facilities,
  water,
  electricity,
  safety,
  sanitation;

  static IncidentCategory fromKey(String? value) {
    return IncidentCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => IncidentCategory.facilities,
    );
  }

  String get key => name;

  String get label => switch (this) {
        IncidentCategory.facilities => 'Facilities',
        IncidentCategory.water => 'Water',
        IncidentCategory.electricity => 'Electricity',
        IncidentCategory.safety => 'Safety',
        IncidentCategory.sanitation => 'Sanitation',
      };
}

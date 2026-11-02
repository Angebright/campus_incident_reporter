/// Incident lifecycle. Persisted in Firestore using the enum `name`.
enum IncidentStatus {
  submitted,
  inProgress,
  resolved;

  static IncidentStatus fromName(String? value) {
    return IncidentStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => IncidentStatus.submitted,
    );
  }

  String get label => switch (this) {
        IncidentStatus.submitted => 'Submitted',
        IncidentStatus.inProgress => 'In Progress',
        IncidentStatus.resolved => 'Resolved',
      };
}

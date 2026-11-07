import 'package:campus_incident_reporter/models/app_user.dart';
import 'package:campus_incident_reporter/models/incident.dart';
import 'package:campus_incident_reporter/models/incident_status.dart';
import 'package:campus_incident_reporter/services/auth_service.dart';
import 'package:campus_incident_reporter/services/incident_service.dart';

class FakeAuthService implements AuthService {
  FakeAuthService({this.profile});

  final AppUser? profile;

  @override
  Stream<String?> authStateChanges() => Stream<String?>.value(profile?.uid);

  @override
  Future<AppUser?> fetchProfile(String uid) async => profile;

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final result = profile;
    if (result == null) {
      throw const AuthException('No profile configured for this fake.');
    }
    return result;
  }

  @override
  Future<AppUser> registerStudent({
    required String name,
    required String email,
    required String password,
    String? department,
  }) async {
    throw const AuthException('Registration is not configured.');
  }

  @override
  Future<void> signOut() async {}
}

class FakeIncidentService implements IncidentService {
  FakeIncidentService({List<Incident>? incidents})
    : _incidents = incidents ?? <Incident>[];

  final List<Incident> _incidents;

  @override
  Stream<List<Incident>> watchMyIncidents(String uid) =>
      Stream<List<Incident>>.value(_incidents);

  @override
  Stream<List<Incident>> streamIncidents() =>
      Stream<List<Incident>>.value(_incidents);

  @override
  Future<void> createIncident(Incident incident) async {
    _incidents.add(incident);
  }

  @override
  Future<void> updateStatus({
    required String incidentId,
    required IncidentStatus newStatus,
    required String changedByName,
  }) async {}
}

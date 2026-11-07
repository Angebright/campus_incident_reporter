import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/incident.dart';
import '../models/incident_category.dart';
import '../models/incident_status.dart';
import '../models/status_entry.dart';
import 'incident_service.dart';

/// Firebase-backed implementation of [IncidentService].
class FirebaseIncidentService implements IncidentService {
  FirebaseIncidentService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _incidents =>
      _firestore.collection('incidents');

  List<Incident> _mapDocs(QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs
        .map((doc) => Incident.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Stream<List<Incident>> watchMyIncidents(String uid) {
    return _incidents
        .where('reportedBy', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_mapDocs);
  }

  @override
  Stream<List<Incident>> streamIncidents() {
    return _incidents
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_mapDocs);
  }

  @override
  Future<void> createIncident(Incident incident) {
    return _incidents.add(incident.toMap()).then((_) {});
  }

  @override
  Future<void> updateIncident({
    required String incidentId,
    required String title,
    required String description,
    required IncidentCategory category,
    required String? imageUrl,
    String? location,
  }) async {
    await _incidents.doc(incidentId).update({
      'title': title,
      'description': description,
      'category': category.key,
      'imageUrl': imageUrl,
      'location': location,
      'updatedAt': DateTime.now(),
    });
  }

  @override
  Future<void> deleteIncident(String incidentId) {
    return _incidents.doc(incidentId).delete();
  }

  @override
  Future<void> updateStatus({
    required String incidentId,
    required IncidentStatus newStatus,
    required String changedByName,
  }) async {
    final entry = StatusEntry(
      status: newStatus,
      changedBy: changedByName,
      timestamp: DateTime.now(),
    );

    await _incidents.doc(incidentId).update({
      'status': newStatus.name,
      'statusHistory': FieldValue.arrayUnion([entry.toMap()]),
      'updatedAt': DateTime.now(),
    });
  }
}

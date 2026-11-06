import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/incident.dart';
import '../models/incident_category.dart';
import '../models/incident_status.dart';
import '../models/status_entry.dart';
import '../services/incident_service.dart';
import '../utils/incident_filters.dart';

/// Owns the signed-in student's reports plus their search/filter state.
class IncidentProvider extends ChangeNotifier {
  IncidentProvider(this._incidentService);

  final IncidentService _incidentService;
  StreamSubscription<List<Incident>>? _subscription;

  List<Incident> _incidents = const [];
  bool _loading = true;
  String? _error;
  String _searchQuery = '';
  IncidentStatus? _statusFilter;
  IncidentCategory? _categoryFilter;
  String? _watchedUid;

  List<Incident> get allIncidents => _incidents;
  bool get loading => _loading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  IncidentStatus? get statusFilter => _statusFilter;
  IncidentCategory? get categoryFilter => _categoryFilter;

  List<Incident> get filteredIncidents => applyIncidentFilters(
    _incidents,
    searchQuery: _searchQuery,
    status: _statusFilter,
    category: _categoryFilter,
  );

  int get totalCount => _incidents.length;
  int get submittedCount => _countByStatus(IncidentStatus.submitted);
  int get inProgressCount => _countByStatus(IncidentStatus.inProgress);
  int get resolvedCount => _countByStatus(IncidentStatus.resolved);

  int _countByStatus(IncidentStatus status) =>
      _incidents.where((incident) => incident.status == status).length;

  void watchMyIncidents(String uid) {
    if (_watchedUid == uid) return;
    _watchedUid = uid;
    _loading = true;
    notifyListeners();
    _listen(uid);
  }

  /// Re-subscribes to the stream so a pull-to-refresh fetches fresh data.
  Future<void> refresh() async {
    final uid = _watchedUid;
    if (uid == null) return;
    final completer = Completer<void>();
    _listen(uid, completer: completer);
    await completer.future.timeout(
      const Duration(seconds: 6),
      onTimeout: () {},
    );
  }

  void _listen(String uid, {Completer<void>? completer}) {
    _subscription?.cancel();
    _subscription = _incidentService
        .watchMyIncidents(uid)
        .listen(
          (incidents) {
            _incidents = incidents;
            _loading = false;
            _error = null;
            notifyListeners();
            if (completer != null && !completer.isCompleted) {
              completer.complete();
            }
          },
          onError: (Object error) {
            _error = 'Could not load your reports. Please try again.';
            _loading = false;
            notifyListeners();
            if (completer != null && !completer.isCompleted) {
              completer.complete();
            }
          },
        );
  }

  void setSearchQuery(String value) {
    if (_searchQuery == value) return;
    _searchQuery = value;
    notifyListeners();
  }

  void setStatusFilter(IncidentStatus? status) {
    if (_statusFilter == status) return;
    _statusFilter = status;
    notifyListeners();
  }

  void setCategoryFilter(IncidentCategory? category) {
    if (_categoryFilter == category) return;
    _categoryFilter = category;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _statusFilter = null;
    _categoryFilter = null;
    notifyListeners();
  }

  Future<bool> submitIncident({
    required AppUser reporter,
    required String title,
    required String description,
    required IncidentCategory category,
    String? location,
    String? imageUrl,
  }) async {
    final now = DateTime.now();
    final incident = Incident(
      id: '',
      title: title.trim(),
      description: description.trim(),
      category: category,
      status: IncidentStatus.submitted,
      reportedBy: reporter.uid,
      reportedByName: reporter.name,
      statusHistory: [
        StatusEntry(
          status: IncidentStatus.submitted,
          changedBy: reporter.name,
          timestamp: now,
        ),
      ],
      createdAt: now,
      location: (location != null && location.trim().isEmpty)
          ? null
          : location?.trim(),
      imageUrl: imageUrl,
    );

    try {
      await _incidentService.createIncident(incident);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

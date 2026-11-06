import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/incident.dart';
import '../models/incident_category.dart';
import '../models/incident_status.dart';
import '../services/incident_service.dart';
import '../utils/incident_filters.dart';

/// Owns all incidents for staff review, plus their search/filter state and the
/// status-update action.
class StaffProvider extends ChangeNotifier {
  StaffProvider(this._incidentService);

  final IncidentService _incidentService;
  StreamSubscription<List<Incident>>? _subscription;

  List<Incident> _incidents = const [];
  bool _loading = true;
  bool _updating = false;
  String? _error;
  String _searchQuery = '';
  IncidentStatus? _statusFilter;
  IncidentCategory? _categoryFilter;
  bool _streaming = false;

  List<Incident> get allIncidents => _incidents;
  bool get loading => _loading;
  bool get updating => _updating;
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

  void streamIncidents() {
    if (_streaming) return;
    _streaming = true;
    _loading = true;
    notifyListeners();
    _listen();
  }

  /// Re-subscribes to the stream so a pull-to-refresh fetches fresh data.
  Future<void> refresh() async {
    if (!_streaming) return;
    final completer = Completer<void>();
    _listen(completer: completer);
    await completer.future.timeout(
      const Duration(seconds: 6),
      onTimeout: () {},
    );
  }

  void _listen({Completer<void>? completer}) {
    _subscription?.cancel();
    _subscription = _incidentService.streamIncidents().listen(
      (incidents) {
        _incidents = incidents;
        _loading = false;
        _error = null;
        notifyListeners();
        if (completer != null && !completer.isCompleted) completer.complete();
      },
      onError: (Object error) {
        _error = 'Could not load reports. Please try again.';
        _loading = false;
        notifyListeners();
        if (completer != null && !completer.isCompleted) completer.complete();
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

  Future<bool> updateStatus({
    required String incidentId,
    required IncidentStatus newStatus,
    required String changedByName,
  }) async {
    _updating = true;
    notifyListeners();
    try {
      await _incidentService.updateStatus(
        incidentId: incidentId,
        newStatus: newStatus,
        changedByName: changedByName,
      );
      _error = null;
      return true;
    } catch (_) {
      _error = 'Could not update the status. Please try again.';
      return false;
    } finally {
      _updating = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

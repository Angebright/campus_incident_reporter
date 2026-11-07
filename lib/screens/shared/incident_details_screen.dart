import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/incident.dart';
import '../../models/incident_status.dart';
import '../../models/status_entry.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../providers/staff_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/incident_style.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/status_timeline.dart';
import '../student/edit_incident_screen.dart';
import 'full_screen_image_screen.dart';

/// Shared incident detail view used by both students and staff.
class IncidentDetailsScreen extends StatefulWidget {
  const IncidentDetailsScreen({super.key, required this.incident});

  final Incident incident;

  @override
  State<IncidentDetailsScreen> createState() => _IncidentDetailsScreenState();
}

class _IncidentDetailsScreenState extends State<IncidentDetailsScreen> {
  late Incident _incident;
  bool _updating = false;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _incident = widget.incident;
  }

  List<_StatusAction> _actionsFor(IncidentStatus status) {
    return switch (status) {
      IncidentStatus.submitted => const [
        _StatusAction(
          label: 'Start Progress',
          status: IncidentStatus.inProgress,
          primary: true,
        ),
        _StatusAction(label: 'Mark Resolved', status: IncidentStatus.resolved),
      ],
      IncidentStatus.inProgress => const [
        _StatusAction(
          label: 'Mark Resolved',
          status: IncidentStatus.resolved,
          primary: true,
        ),
      ],
      IncidentStatus.resolved => const [
        _StatusAction(
          label: 'Reopen',
          status: IncidentStatus.inProgress,
          primary: true,
        ),
      ],
    };
  }

  Future<void> _updateStatus(
    Incident incident,
    IncidentStatus newStatus,
  ) async {
    final auth = context.read<AuthProvider>();
    final staff = context.read<StaffProvider>();
    final changedBy = auth.user?.name ?? 'Staff';

    setState(() => _updating = true);
    final success = await staff.updateStatus(
      incidentId: incident.id,
      newStatus: newStatus,
      changedByName: changedBy,
    );
    if (!mounted) return;

    setState(() {
      _updating = false;
      if (success) {
        _incident = incident.copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
          statusHistory: [
            ...incident.statusHistory,
            StatusEntry(
              status: newStatus,
              changedBy: changedBy,
              timestamp: DateTime.now(),
            ),
          ],
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Status updated to ${newStatus.label}'
              : (staff.error ?? 'Could not update the status'),
        ),
      ),
    );
  }

  Incident _resolveCurrent(BuildContext context, bool isStaff) {
    final incidents = isStaff
        ? context.watch<StaffProvider>().allIncidents
        : context.watch<IncidentProvider>().allIncidents;
    for (final incident in incidents) {
      if (incident.id == _incident.id) return incident;
    }
    return _incident;
  }

  Future<void> _edit(Incident incident) async {
    final updated = await Navigator.of(context).push<Incident>(
      MaterialPageRoute(builder: (_) => EditIncidentScreen(incident: incident)),
    );
    if (updated != null && mounted) {
      setState(() => _incident = updated);
    }
  }

  Future<void> _delete(Incident incident) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete report?'),
        content: const Text('This report will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _deleting = true);
    final success = await context.read<IncidentProvider>().deleteIncident(
      incident.id,
    );
    if (!mounted) return;
    setState(() => _deleting = false);

    if (success) {
      Navigator.of(context).pop();
      messenger.showSnackBar(const SnackBar(content: Text('Report deleted')));
    } else {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not delete the report. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isStaff = auth.isStaff;
    final incident = _resolveCurrent(context, isStaff);
    final isReporter = auth.user?.uid == incident.reportedBy;
    final canModify =
        !isStaff && isReporter && incident.status == IncidentStatus.submitted;

    return Scaffold(
      appBar: AppBar(title: const Text('Report details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderCard(incident: incident),
            const SizedBox(height: 20),
            _SectionCard(
              title: 'Progress',
              child: Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 4),
                child: StatusTimeline(current: incident.status),
              ),
            ),
            if (incident.imageUrl != null &&
                incident.imageUrl!.trim().isNotEmpty) ...[
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        FullScreenImageScreen(imageUrl: incident.imageUrl!),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppColors.radius),
                  child: Image.network(
                    incident.imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            _SectionCard(
              title: 'Description',
              child: Text(
                incident.description,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.55,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _SectionCard(
              title: 'Status history',
              child: Column(
                children: [
                  for (final entry in incident.statusHistory.reversed)
                    _HistoryTile(entry: entry),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isStaff
          ? _StaffActionBar(
              actions: _actionsFor(incident.status),
              busy: _updating,
              onSelected: (status) => _updateStatus(incident, status),
            )
          : canModify
          ? _StudentActionBar(
              busy: _deleting,
              onEdit: () => _edit(incident),
              onDelete: () => _delete(incident),
            )
          : null,
    );
  }
}

class _StatusAction {
  const _StatusAction({
    required this.label,
    required this.status,
    this.primary = false,
  });

  final String label;
  final IncidentStatus status;
  final bool primary;
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.incident});

  final Incident incident;

  @override
  Widget build(BuildContext context) {
    final categoryColorValue = categoryColor(incident.category);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  incident.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              StatusChip(status: incident.status),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Pill(
                icon: categoryIcon(incident.category),
                label: incident.category.label,
                color: categoryColorValue,
              ),
              if (incident.location != null)
                _Pill(
                  icon: Icons.place_outlined,
                  label: incident.location!,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: 15,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  incident.reportedByName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formatFullDateTime(incident.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry});

  final StatusEntry entry;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(entry.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 3),
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.status.label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.changedBy} • ${formatFullDateTime(entry.timestamp)}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StaffActionBar extends StatelessWidget {
  const _StaffActionBar({
    required this.actions,
    required this.busy,
    required this.onSelected,
  });

  final List<_StatusAction> actions;
  final bool busy;
  final ValueChanged<IncidentStatus> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            for (var i = 0; i < actions.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(
                child: actions[i].primary
                    ? ElevatedButton(
                        onPressed: busy
                            ? null
                            : () => onSelected(actions[i].status),
                        child: busy
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(actions[i].label),
                      )
                    : OutlinedButton(
                        onPressed: busy
                            ? null
                            : () => onSelected(actions[i].status),
                        child: Text(actions[i].label),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StudentActionBar extends StatelessWidget {
  const _StudentActionBar({
    required this.busy,
    required this.onEdit,
    required this.onDelete,
  });

  final bool busy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: busy ? null : onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: busy ? null : onDelete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                icon: busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.delete_outline, size: 18),
                label: const Text('Delete'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

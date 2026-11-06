import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/incident.dart';
import '../../models/incident_status.dart';
import '../../providers/auth_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/staff_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/profile_avatar.dart';
import '../../widgets/skeleton_card.dart';
import '../../widgets/summary_card.dart';
import '../shared/incident_details_screen.dart';

class StaffReportsScreen extends StatelessWidget {
  const StaffReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final staff = context.watch<StaffProvider>();
    final firstName = user?.name.trim().split(' ').first ?? 'there';
    final incidents = staff.filteredIncidents;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, $firstName 👋',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Review and update campus reports.',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ProfileAvatar(
                      name: user?.name ?? '',
                      onTap: () =>
                          context.read<NavigationProvider>().setIndex(1),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _StatusSummaryRow(staff: staff),
                const SizedBox(height: 14),
                TextField(
                  onChanged: staff.setSearchQuery,
                  decoration: const InputDecoration(
                    hintText: 'Search reports',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: staff.refresh,
              child: _buildList(context, staff, incidents),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    StaffProvider staff,
    List<Incident> incidents,
  ) {
    if (staff.loading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        children: const [
          SkeletonCard(),
          SizedBox(height: 10),
          SkeletonCard(),
          SizedBox(height: 10),
          SkeletonCard(),
        ],
      );
    }

    if (staff.error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 80),
        children: [ErrorState(message: staff.error!)],
      );
    }

    if (incidents.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 80),
        children: const [
          EmptyState(
            icon: Icons.inbox_outlined,
            title: 'No reports found',
            message: 'There are no reports matching this view yet.',
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: incidents.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final incident = incidents[index];
        return IncidentCard(
          incident: incident,
          showReporter: true,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => IncidentDetailsScreen(incident: incident),
            ),
          ),
        );
      },
    );
  }
}

class _StatusSummaryRow extends StatelessWidget {
  const _StatusSummaryRow({required this.staff});

  final StaffProvider staff;

  @override
  Widget build(BuildContext context) {
    final filter = staff.statusFilter;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(
            width: 112,
            child: SummaryCard(
              icon: Icons.list_alt_outlined,
              count: staff.totalCount,
              label: 'All',
              selected: filter == null,
              onTap: () => staff.setStatusFilter(null),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 112,
            child: SummaryCard(
              icon: Icons.send_outlined,
              count: staff.submittedCount,
              label: 'Submitted',
              color: AppColors.submitted,
              selected: filter == IncidentStatus.submitted,
              onTap: () => staff.setStatusFilter(IncidentStatus.submitted),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 112,
            child: SummaryCard(
              icon: Icons.construction_outlined,
              count: staff.inProgressCount,
              label: 'In progress',
              color: AppColors.inProgress,
              selected: filter == IncidentStatus.inProgress,
              onTap: () => staff.setStatusFilter(IncidentStatus.inProgress),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 112,
            child: SummaryCard(
              icon: Icons.check_circle_outline,
              count: staff.resolvedCount,
              label: 'Resolved',
              color: AppColors.resolved,
              selected: filter == IncidentStatus.resolved,
              onTap: () => staff.setStatusFilter(IncidentStatus.resolved),
            ),
          ),
        ],
      ),
    );
  }
}

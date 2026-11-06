import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/incident.dart';
import '../../models/incident_category.dart';
import '../../models/incident_status.dart';
import '../../providers/incident_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/skeleton_card.dart';
import '../shared/incident_details_screen.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    final incidents = provider.filteredIncidents;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Reports',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${provider.totalCount} report${provider.totalCount == 1 ? '' : 's'} submitted',
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: provider.setSearchQuery,
                  decoration: const InputDecoration(
                    hintText: 'Search your reports',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 12),
                _StatusFilterRow(provider: provider),
                const SizedBox(height: 10),
                _CategoryFilter(provider: provider),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: provider.refresh,
              child: _buildList(context, provider, incidents),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    IncidentProvider provider,
    List<Incident> incidents,
  ) {
    if (provider.loading) {
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

    if (provider.error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 80),
        children: [ErrorState(message: provider.error!)],
      );
    }

    if (incidents.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 80),
        children: const [
          EmptyState(
            icon: Icons.search_off,
            title: 'No matching reports',
            message: 'Try changing your search or filters.',
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

class _StatusFilterRow extends StatelessWidget {
  const _StatusFilterRow({required this.provider});

  final IncidentProvider provider;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            selected: provider.statusFilter == null,
            onTap: () => provider.setStatusFilter(null),
          ),
          for (final status in IncidentStatus.values)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _FilterChip(
                label: status.label,
                selected: provider.statusFilter == status,
                onTap: () => provider.setStatusFilter(status),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({required this.provider});

  final IncidentProvider provider;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<IncidentCategory?>(
      initialValue: provider.categoryFilter,
      isExpanded: true,
      decoration: const InputDecoration(
        hintText: 'All categories',
        prefixIcon: Icon(Icons.category_outlined),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: [
        const DropdownMenuItem<IncidentCategory?>(
          value: null,
          child: Text('All categories'),
        ),
        for (final category in IncidentCategory.values)
          DropdownMenuItem<IncidentCategory?>(
            value: category,
            child: Text(category.label),
          ),
      ],
      onChanged: provider.setCategoryFilter,
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

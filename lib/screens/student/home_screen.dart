import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/incident.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/skeleton_card.dart';
import '../../widgets/summary_card.dart';
import '../shared/incident_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final incidents = context.watch<IncidentProvider>();
    final firstName = user?.name.trim().split(' ').first ?? 'there';
    final recent = incidents.allIncidents.take(3).toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          Text(
            'Hello, $firstName',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Here's what's happening on campus.",
            style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          _ReportCta(
            onTap: () => context.read<NavigationProvider>().setIndex(1),
          ),
          const SizedBox(height: 24),
          const _SectionHeading(title: 'Your reports'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  icon: Icons.send_outlined,
                  count: incidents.submittedCount,
                  label: 'Submitted',
                  color: AppColors.submitted,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SummaryCard(
                  icon: Icons.construction_outlined,
                  count: incidents.inProgressCount,
                  label: 'In progress',
                  color: AppColors.inProgress,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SummaryCard(
                  icon: Icons.check_circle_outline,
                  count: incidents.resolvedCount,
                  label: 'Resolved',
                  color: AppColors.resolved,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionHeading(
            title: 'Recent reports',
            actionLabel: 'See all',
            onAction: () => context.read<NavigationProvider>().setIndex(2),
          ),
          const SizedBox(height: 12),
          if (incidents.loading)
            const Column(
              children: [
                SkeletonCard(),
                SizedBox(height: 10),
                SkeletonCard(),
              ],
            )
          else if (recent.isEmpty)
            const EmptyState(
              icon: Icons.inbox_outlined,
              title: 'No reports yet',
              message:
                  'Tap "Report an issue" to submit your first campus report.',
            )
          else
            for (final incident in recent)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: IncidentCard(
                  incident: incident,
                  onTap: () => _openDetails(context, incident),
                ),
              ),
        ],
      ),
    );
  }

  void _openDetails(BuildContext context, Incident incident) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => IncidentDetailsScreen(incident: incident),
      ),
    );
  }
}

class _ReportCta extends StatelessWidget {
  const _ReportCta({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(AppColors.radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppColors.radius),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.campaign_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Report an issue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Facilities, water, electricity and more',
                      style: TextStyle(color: Colors.white70, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

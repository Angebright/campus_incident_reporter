import 'package:flutter/material.dart';

import '../models/incident.dart';
import '../theme/app_theme.dart';
import '../theme/incident_style.dart';
import '../utils/date_formatter.dart';
import 'status_chip.dart';

/// A report row used on the student and staff lists.
class IncidentCard extends StatelessWidget {
  const IncidentCard({
    super.key,
    required this.incident,
    this.showReporter = false,
    this.onTap,
  });

  final Incident incident;
  final bool showReporter;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = categoryColor(incident.category);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppColors.radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppColors.radius),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppColors.radius),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Thumbnail(incident: incident, accent: accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            incident.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusChip(status: incident.status, compact: true),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      [
                        incident.category.label,
                        if (incident.location != null)
                          incident.location!,
                      ].join('  •  '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formatRelativeTime(incident.createdAt),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (showReporter) ...[
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.person_outline,
                            size: 13,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              incident.reportedByName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.incident, required this.accent});

  final Incident incident;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final hasImage =
        incident.imageUrl != null && incident.imageUrl!.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 46,
        height: 46,
        color: accent.withValues(alpha: 0.12),
        child: hasImage
            ? Image.network(
                incident.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _iconFallback(accent),
              )
            : _iconFallback(accent),
      ),
    );
  }

  Widget _iconFallback(Color color) {
    return Icon(categoryIcon(incident.category), color: color, size: 22);
  }
}

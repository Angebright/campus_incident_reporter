import 'package:flutter/material.dart';

import '../models/incident_category.dart';
import '../models/incident_status.dart';
import 'app_theme.dart';

/// Solid accent color for a status.
Color statusColor(IncidentStatus status) {
  return switch (status) {
    IncidentStatus.submitted => AppColors.submitted,
    IncidentStatus.inProgress => AppColors.inProgress,
    IncidentStatus.resolved => AppColors.resolved,
  };
}

/// Light tint used as a chip background for a status.
Color statusBackground(IncidentStatus status) {
  return statusColor(status).withValues(alpha: 0.12);
}

IconData categoryIcon(IncidentCategory category) {
  return switch (category) {
    IncidentCategory.facilities => Icons.build_outlined,
    IncidentCategory.water => Icons.water_drop_outlined,
    IncidentCategory.electricity => Icons.bolt_outlined,
    IncidentCategory.safety => Icons.shield_outlined,
    IncidentCategory.sanitation => Icons.cleaning_services_outlined,
  };
}

Color categoryColor(IncidentCategory category) {
  return switch (category) {
    IncidentCategory.facilities => const Color(0xFF6366F1),
    IncidentCategory.water => const Color(0xFF0EA5E9),
    IncidentCategory.electricity => const Color(0xFFF59E0B),
    IncidentCategory.safety => const Color(0xFFEF4444),
    IncidentCategory.sanitation => const Color(0xFF10B981),
  };
}

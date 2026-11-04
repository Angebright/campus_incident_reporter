import 'package:flutter/material.dart';

import '../models/incident_status.dart';
import '../theme/incident_style.dart';

/// Small pill badge showing an incident status with its colour mapping.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status, this.compact = false});

  final IncidentStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: statusBackground(status),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

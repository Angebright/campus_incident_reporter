import 'package:flutter/material.dart';

import '../models/incident_status.dart';
import '../theme/app_theme.dart';
import '../theme/incident_style.dart';

/// Horizontal stepper (Submitted -> In Progress -> Resolved) with an animated
/// fill and a pulsing current node.
class StatusTimeline extends StatefulWidget {
  const StatusTimeline({super.key, required this.current});

  final IncidentStatus current;

  @override
  State<StatusTimeline> createState() => _StatusTimelineState();
}

class _StatusTimelineState extends State<StatusTimeline>
    with SingleTickerProviderStateMixin {
  static const List<IncidentStatus> _steps = IncidentStatus.values;
  static const double _nodeSize = 26;

  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  int get _currentIndex => _steps.indexOf(widget.current);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _steps.length; i++) ...[
          _buildNode(i),
          if (i < _steps.length - 1) _buildConnector(i),
        ],
      ],
    );
  }

  Widget _buildNode(int index) {
    final status = _steps[index];
    final isDone = index < _currentIndex;
    final isCurrent = index == _currentIndex;
    final color = statusColor(status);

    Widget circle;
    if (isDone) {
      circle = Container(
        width: _nodeSize,
        height: _nodeSize,
        decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        child: const Icon(Icons.check, size: 15, color: Colors.white),
      );
    } else if (isCurrent) {
      final scale = Tween<double>(begin: 1.0, end: 1.12).animate(
        CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
      );
      circle = ScaleTransition(
        scale: scale,
        child: Container(
          width: _nodeSize,
          height: _nodeSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 0,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Center(
            child: SizedBox(
              width: 8,
              height: 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      circle = Container(
        width: _nodeSize,
        height: _nodeSize,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border, width: 2),
        ),
      );
    }

    return SizedBox(
      width: 78,
      child: Column(
        children: [
          circle,
          const SizedBox(height: 6),
          Text(
            status.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
              color: isDone || isCurrent
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnector(int index) {
    final active = _currentIndex > index;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: _nodeSize / 2 - 1.5),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 3,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

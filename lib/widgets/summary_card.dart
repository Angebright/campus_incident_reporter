import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A compact stat tile showing an icon, a count, and a label. Used for the
/// summary row on Home and the staff status filters.
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.icon,
    required this.count,
    required this.label,
    this.color = AppColors.primary,
    this.selected = false,
    this.onTap,
  });

  final IconData icon;
  final int count;
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color.withValues(alpha: 0.08) : AppColors.surface,
      borderRadius: BorderRadius.circular(AppColors.radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppColors.radius),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppColors.radius),
            border: Border.all(
              color: selected ? color : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 12),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

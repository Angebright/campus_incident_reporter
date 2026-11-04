import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Pulsing placeholder row shown while reports are loading.
class SkeletonCard extends StatefulWidget {
  const SkeletonCard({super.key});

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.5, end: 1.0).animate(_controller),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppColors.radius),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            _bar(width: 46, height: 46, radius: 12),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bar(width: 160, height: 14),
                  const SizedBox(height: 10),
                  _bar(width: 110, height: 11),
                  const SizedBox(height: 8),
                  _bar(width: 80, height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bar({required double width, required double height, double radius = 6}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

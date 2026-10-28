import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class PageScrubber extends StatelessWidget {
  const PageScrubber({
    required this.count,
    required this.currentPage,
    required this.onPageSelected,
    this.color = AppColors.darkCoffee,
    this.inactiveColor = AppColors.mediumCoffee,
    this.height = 26,
    super.key,
  });

  final int count;
  final int currentPage;
  final ValueChanged<int> onPageSelected;
  final Color color;
  final Color inactiveColor;
  final double height;

  void _selectAt(double localX, double totalWidth, double trackWidth) {
    if (count <= 1 || totalWidth <= 0 || trackWidth <= 0) {
      return;
    }
    final startX = (totalWidth - trackWidth) / 2;
    final relativeX = localX - startX;
    final page = ((relativeX / trackWidth) * count).floor().clamp(0, count - 1);
    onPageSelected(page);
  }

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return const SizedBox.shrink();
    }

    final page = currentPage.clamp(0, count - 1);
    final trackWidth = (count * 20.0 + 32.0).clamp(80.0, 220.0);

    return SizedBox(
      width: double.infinity,
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) =>
                  _selectAt(details.localPosition.dx, totalWidth, trackWidth),
              onHorizontalDragStart: (details) =>
                  _selectAt(details.localPosition.dx, totalWidth, trackWidth),
              onHorizontalDragUpdate: (details) =>
                  _selectAt(details.localPosition.dx, totalWidth, trackWidth),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: inactiveColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(count, (index) {
                      final isSelected = page == index;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.5),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          width: isSelected ? 20 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color
                                : inactiveColor.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.28),
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

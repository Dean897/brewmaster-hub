import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class PageScrubber extends StatelessWidget {
  const PageScrubber({
    required this.count,
    required this.currentPage,
    required this.onPageSelected,
    this.color = AppColors.darkCoffee,
    this.inactiveColor = AppColors.mediumCoffee,
    super.key,
  });

  final int count;
  final int currentPage;
  final ValueChanged<int> onPageSelected;
  final Color color;
  final Color inactiveColor;

  void _selectAt(double localX, double width) {
    if (count <= 1 || width <= 0) {
      return;
    }
    final page = ((localX / width) * (count - 1)).round().clamp(0, count - 1);
    onPageSelected(page);
  }

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return const SizedBox.shrink();
    }

    final page = currentPage.clamp(0, count - 1);
    return SizedBox(
      width: double.infinity,
      height: 36,
      child: LayoutBuilder(
        builder: (context, constraints) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) =>
              _selectAt(details.localPosition.dx, constraints.maxWidth),
          onHorizontalDragStart: (details) =>
              _selectAt(details.localPosition.dx, constraints.maxWidth),
          onHorizontalDragUpdate: (details) =>
              _selectAt(details.localPosition.dx, constraints.maxWidth),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(count, (index) {
              final isSelected = page == index;
              return Expanded(
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    width: isSelected ? 24 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color
                          : inactiveColor.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

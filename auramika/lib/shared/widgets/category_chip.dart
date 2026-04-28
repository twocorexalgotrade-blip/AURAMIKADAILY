import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';

/// AURAMIKA Category Chip
///
/// Design: Rectangular "clothing tag" aesthetic
///   • Thin 1px border (selected: Forest Green, unselected: divider)
///   • Sharp 4px corners — brand standard
///   • Uppercase Outfit text with wide letter-spacing
///   • Selected: Forest Green fill + white text
///   • Unselected: Cream fill + dark text
///   • Animated fill transition on selection
///   • Optional count badge
class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? count;
  final IconData? icon;
  final int animationIndex;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.count,
    this.icon,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: icon != null
              ? AppConstants.paddingS + 2
              : AppConstants.paddingM,
          vertical: AppConstants.paddingS - 2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.forestGreen : AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
          border: Border.all(
            color: isSelected ? AppColors.forestGreen : AppColors.divider,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 12,
                color: isSelected ? AppColors.white : AppColors.textMuted,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label.toUpperCase(),
              style: AppTextStyles.categoryChip.copyWith(
                color: isSelected ? AppColors.white : AppColors.textPrimary,
                fontSize: 10,
                letterSpacing: 1.5,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 5),
              AnimatedContainer(
                duration: AppConstants.animFast,
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.white.withValues(alpha: 0.25)
                      : AppColors.divider,
                  borderRadius: BorderRadius.circular(AppConstants.radiusXS),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? AppColors.white : AppColors.textMuted,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: animationIndex * 50))
        .fadeIn(duration: AppConstants.animFast)
        .slideX(begin: 0.1, end: 0, duration: AppConstants.animFast);
  }
}

/// Horizontal scrollable row of [CategoryChip]s
class CategoryChipRow extends StatefulWidget {
  final List<String> categories;
  final int initialIndex;
  final ValueChanged<int> onChanged;
  final List<int>? counts;
  final EdgeInsets? padding;

  const CategoryChipRow({
    super.key,
    required this.categories,
    required this.onChanged,
    this.initialIndex = 0,
    this.counts,
    this.padding,
  });

  @override
  State<CategoryChipRow> createState() => _CategoryChipRowState();
}

class _CategoryChipRowState extends State<CategoryChipRow> {
  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: widget.padding ??
            const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
        itemCount: widget.categories.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: AppConstants.paddingS),
        itemBuilder: (context, i) {
          return CategoryChip(
            label: widget.categories[i],
            isSelected: i == _selected,
            count: widget.counts != null && i < widget.counts!.length
                ? widget.counts![i]
                : null,
            animationIndex: i,
            onTap: () {
              setState(() => _selected = i);
              widget.onChanged(i);
            },
          );
        },
      ),
    );
  }
}

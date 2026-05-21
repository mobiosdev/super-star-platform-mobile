import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/light_blue_theme.dart';

class RoleBottomNav extends StatelessWidget {
  const RoleBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavItem> items;

  static const double _barHeight = 76;
  static const double _indicatorSize = 64;
  static const double _circleContentInset = 10;
  static const Duration _slideDuration = Duration(milliseconds: 320);

  @override
  Widget build(BuildContext context) {
    final index = currentIndex.clamp(0, items.length - 1);

    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: _barHeight,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(_barHeight / 2),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final slotWidth = constraints.maxWidth / items.length;
                final indicatorLeft =
                    slotWidth * index + (slotWidth - _indicatorSize) / 2;
                const indicatorTop = (_barHeight - _indicatorSize) / 2;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedPositioned(
                      duration: _slideDuration,
                      curve: Curves.easeOutCubic,
                      left: indicatorLeft,
                      top: indicatorTop,
                      width: _indicatorSize,
                      height: _indicatorSize,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LightBlueTheme.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(items.length, (i) {
                        final selected = i == index;
                        final item = items[i];
                        return Expanded(
                          child: _NavSlot(
                            item: item,
                            selected: selected,
                            onTap: () => onTap(i),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NavSlot extends StatelessWidget {
  const _NavSlot({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final BottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = selected ? (item.selectedIcon ?? item.icon) : item.icon;
    final iconColor = selected ? Colors.white : AppColors.textSecondary;
    final labelColor = selected ? Colors.white : AppColors.textSecondary;
    final iconSize = selected ? 22.0 : 24.0;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedScale(
          scale: selected ? 1.05 : 1,
          duration: RoleBottomNav._slideDuration,
          curve: Curves.easeOutCubic,
          child: Icon(icon, size: iconSize, color: iconColor),
        ),
        SizedBox(height: selected ? 3 : 2),
        AnimatedDefaultTextStyle(
          duration: RoleBottomNav._slideDuration,
          curve: Curves.easeOutCubic,
          style: Theme.of(context).textTheme.labelSmall!.copyWith(
                fontSize: selected ? 10 : 10,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: labelColor,
              ),
          child: Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(36),
        splashColor: AppColors.primary.withOpacity(0.12),
        highlightColor: AppColors.primary.withOpacity(0.06),
        child: SizedBox(
          height: RoleBottomNav._barHeight,
          child: Center(
            child: selected
                ? SizedBox(
                    width: RoleBottomNav._indicatorSize -
                        RoleBottomNav._circleContentInset * 2,
                    height: RoleBottomNav._indicatorSize -
                        RoleBottomNav._circleContentInset * 2,
                    child: content,
                  )
                : content,
          ),
        ),
      ),
    );
  }
}

class BottomNavItem {
  const BottomNavItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
}

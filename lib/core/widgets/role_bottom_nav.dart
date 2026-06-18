import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/light_blue_theme.dart';

class RoleBottomNav extends StatefulWidget {
  const RoleBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavItem> items;

  static const double _barHeight = 58;
  static const double _indicatorHeight = 42;
  static const double _indicatorPaddingHorizontal = 8;
  static const Duration _slideDuration = Duration(milliseconds: 380);

  @override
  State<RoleBottomNav> createState() => _RoleBottomNavState();
}

class _RoleBottomNavState extends State<RoleBottomNav> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _prevIndex = 0;
  double _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _prevIndex = widget.currentIndex.toDouble();
    _currentIndex = widget.currentIndex.toDouble();
    _controller = AnimationController(
      vsync: this,
      duration: RoleBottomNav._slideDuration,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant RoleBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _prevIndex = _currentIndex;
      _currentIndex = widget.currentIndex.toDouble();
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeIndex = widget.currentIndex.clamp(0, widget.items.length - 1);

    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Material(
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(RoleBottomNav._barHeight / 2),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                height: RoleBottomNav._barHeight,
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(RoleBottomNav._barHeight / 2),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final slotWidth = constraints.maxWidth / widget.items.length;
                    final normalWidth = slotWidth - (RoleBottomNav._indicatorPaddingHorizontal * 2);

                    return AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        final t = _animation.value;
                        final startLeft = _prevIndex * slotWidth + RoleBottomNav._indicatorPaddingHorizontal;
                        final endLeft = _currentIndex * slotWidth + RoleBottomNav._indicatorPaddingHorizontal;

                        // Liquid stretching physics:
                        final double tLeft;
                        final double tRight;
                        if (endLeft >= startLeft) {
                          tLeft = Curves.easeInCubic.transform(t);
                          tRight = Curves.easeOutCubic.transform(t);
                        } else {
                          tLeft = Curves.easeOutCubic.transform(t);
                          tRight = Curves.easeInCubic.transform(t);
                        }

                        double left = startLeft + (endLeft - startLeft) * tLeft;
                        double right = (startLeft + normalWidth) + (endLeft - startLeft) * tRight;
                        double width = right - left;

                        // Cap the maximum liquid stretching for a refined dock look
                        final maxAllowedWidth = normalWidth + 24;
                        if (width > maxAllowedWidth) {
                          final excess = width - maxAllowedWidth;
                          if (endLeft >= startLeft) {
                            left += excess;
                          }
                          width = maxAllowedWidth;
                        }

                        const indicatorTop = (RoleBottomNav._barHeight - RoleBottomNav._indicatorHeight) / 2;

                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: left,
                              top: indicatorTop,
                              width: width,
                              height: RoleBottomNav._indicatorHeight,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(21),
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
                              children: List.generate(widget.items.length, (i) {
                                final selected = i == activeIndex;
                                final item = widget.items[i];
                                return Expanded(
                                  child: _NavSlot(
                                    item: item,
                                    selected: selected,
                                    onTap: () => widget.onTap(i),
                                  ),
                                );
                              }),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
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
    final labelColor = selected ? Colors.white : AppColors.textSecondary;
    const iconSize = 20.0;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedScale(
          scale: selected ? 1.05 : 1.0,
          duration: RoleBottomNav._slideDuration,
          curve: Curves.easeOutCubic,
          child: TweenAnimationBuilder<Color?>(
            tween: ColorTween(
              end: selected ? Colors.white : AppColors.textSecondary,
            ),
            duration: RoleBottomNav._slideDuration,
            curve: Curves.easeOutCubic,
            builder: (context, color, child) {
              return Icon(icon, size: iconSize, color: color);
            },
          ),
        ),
        const SizedBox(height: 2),
        AnimatedDefaultTextStyle(
          duration: RoleBottomNav._slideDuration,
          curve: Curves.easeOutCubic,
          style: Theme.of(context).textTheme.labelSmall!.copyWith(
                fontSize: 9.5,
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
            child: content,
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CustomTabBarVariant {
  standard,
  segmented,
  pills,
  underlined,
}

class CustomTabBar extends StatelessWidget {
  final List<CustomTab> tabs;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final CustomTabBarVariant variant;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? indicatorColor;
  final bool isScrollable;
  final EdgeInsetsGeometry? padding;

  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    this.onTap,
    this.variant = CustomTabBarVariant.standard,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.indicatorColor,
    this.isScrollable = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case CustomTabBarVariant.segmented:
        return _buildSegmentedTabBar(context);
      case CustomTabBarVariant.pills:
        return _buildPillsTabBar(context);
      case CustomTabBarVariant.underlined:
        return _buildUnderlinedTabBar(context);
      default:
        return _buildStandardTabBar(context);
    }
  }

  Widget _buildStandardTabBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: backgroundColor ?? theme.colorScheme.surface,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        tabs: tabs
            .map((tab) => Tab(
                  text: tab.label,
                  icon: tab.icon != null ? Icon(tab.icon, size: 20) : null,
                ))
            .toList(),
        isScrollable: isScrollable,
        labelColor: selectedColor ?? theme.tabBarTheme.labelColor,
        unselectedLabelColor:
            unselectedColor ?? theme.tabBarTheme.unselectedLabelColor,
        indicatorColor: indicatorColor ?? theme.tabBarTheme.indicatorColor,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w400,
        ),
        onTap: (index) {
          HapticFeedback.lightImpact();
          if (onTap != null) onTap!(index);
        },
      ),
    );
  }

  Widget _buildSegmentedTabBar(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = this.selectedColor ?? theme.colorScheme.primary;
    final unselectedColor =
        this.unselectedColor ?? theme.colorScheme.onSurface.withAlpha(153);

    return Container(
      margin: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withAlpha(51),
        ),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = index == currentIndex;
          final isFirst = index == 0;
          final isLast = index == tabs.length - 1;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                if (onTap != null) onTap!(index);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? selectedColor : Colors.transparent,
                  borderRadius: BorderRadius.horizontal(
                    left: isFirst ? const Radius.circular(12) : Radius.zero,
                    right: isLast ? const Radius.circular(12) : Radius.zero,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (tab.icon != null) ...[
                      Icon(
                        tab.icon,
                        size: 18,
                        color: isSelected ? Colors.white : unselectedColor,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      tab.label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isSelected ? Colors.white : unselectedColor,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPillsTabBar(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = this.selectedColor ?? theme.colorScheme.primary;
    final unselectedColor =
        this.unselectedColor ?? theme.colorScheme.onSurface.withAlpha(153);

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isSelected = index == currentIndex;

            return Padding(
              padding: EdgeInsets.only(right: index < tabs.length - 1 ? 12 : 0),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (onTap != null) onTap!(index);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? selectedColor : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? selectedColor
                          : theme.colorScheme.outline.withAlpha(77),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (tab.icon != null) ...[
                        Icon(
                          tab.icon,
                          size: 16,
                          color: isSelected ? Colors.white : unselectedColor,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        tab.label,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: isSelected ? Colors.white : unselectedColor,
                          fontWeight:
                              isSelected ? FontWeight.w500 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildUnderlinedTabBar(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = this.selectedColor ?? theme.colorScheme.primary;
    final unselectedColor =
        this.unselectedColor ?? theme.colorScheme.onSurface.withAlpha(153);

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withAlpha(51),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = index == currentIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                if (onTap != null) onTap!(index);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? selectedColor : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (tab.icon != null) ...[
                      Icon(
                        tab.icon,
                        size: 18,
                        color: isSelected ? selectedColor : unselectedColor,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      tab.label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: isSelected ? selectedColor : unselectedColor,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class CustomTab {
  final String label;
  final IconData? icon;
  final String? route;

  const CustomTab({
    required this.label,
    this.icon,
    this.route,
  });
}

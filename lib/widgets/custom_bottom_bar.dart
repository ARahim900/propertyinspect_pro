import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CustomBottomBarVariant {
  standard,
  floating,
  minimal,
}

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final CustomBottomBarVariant variant;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double? elevation;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    this.onTap,
    this.variant = CustomBottomBarVariant.standard,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.elevation,
  });

  static const List<_BottomBarItem> _items = [
    _BottomBarItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Dashboard',
      route: '/dashboard-screen',
    ),
    _BottomBarItem(
      icon: Icons.schedule_outlined,
      selectedIcon: Icons.schedule,
      label: 'Schedule',
      route: '/schedule-list-screen',
    ),
    _BottomBarItem(
      icon: Icons.assignment_outlined,
      selectedIcon: Icons.assignment,
      label: 'Inspections',
      route: '/inspection-detail-screen',
    ),
    _BottomBarItem(
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
      label: 'Invoices',
      route: '/invoice-generation-screen',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (variant) {
      case CustomBottomBarVariant.floating:
        return _buildFloatingBottomBar(context);
      case CustomBottomBarVariant.minimal:
        return _buildMinimalBottomBar(context);
      default:
        return _buildStandardBottomBar(context);
    }
  }

  Widget _buildStandardBottomBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color:
            backgroundColor ?? theme.bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == currentIndex;

              return _buildBottomBarItem(
                context,
                item,
                isSelected,
                () => _handleTap(context, index, item.route),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingBottomBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withAlpha(38),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = index == currentIndex;

                  return _buildBottomBarItem(
                    context,
                    item,
                    isSelected,
                    () => _handleTap(context, index, item.route),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalBottomBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withAlpha(51),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == currentIndex;

              return _buildMinimalBottomBarItem(
                context,
                item,
                isSelected,
                () => _handleTap(context, index, item.route),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBarItem(
    BuildContext context,
    _BottomBarItem item,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final selectedColor =
        selectedItemColor ?? theme.bottomNavigationBarTheme.selectedItemColor;
    final unselectedColor = unselectedItemColor ??
        theme.bottomNavigationBarTheme.unselectedItemColor;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? item.selectedIcon : item.icon,
                size: 24,
                color: isSelected ? selectedColor : unselectedColor,
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isSelected ? selectedColor : unselectedColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalBottomBarItem(
    BuildContext context,
    _BottomBarItem item,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final selectedColor = selectedItemColor ?? theme.colorScheme.primary;
    final unselectedColor =
        unselectedItemColor ?? theme.colorScheme.onSurface.withAlpha(153);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Icon(
          isSelected ? item.selectedIcon : item.icon,
          size: 24,
          color: isSelected ? selectedColor : unselectedColor,
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, int index, String route) {
    HapticFeedback.lightImpact();

    if (onTap != null) {
      onTap!(index);
    }

    // Navigate to the selected route if it's different from current
    if (index != currentIndex) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        route,
        (route) => false,
      );
    }
  }
}

class _BottomBarItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;

  const _BottomBarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });
}

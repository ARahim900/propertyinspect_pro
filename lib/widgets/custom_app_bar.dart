import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CustomAppBarVariant {
  standard,
  withSearch,
  withActions,
  minimal,
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final CustomAppBarVariant variant;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final VoidCallback? onSearchTap;
  final String? searchHint;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.variant = CustomAppBarVariant.standard,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.onSearchTap,
    this.searchHint,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: _buildTitle(context),
      leading: _buildLeading(context),
      actions: _buildActions(context),
      automaticallyImplyLeading: automaticallyImplyLeading && showBackButton,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? theme.appBarTheme.backgroundColor,
      foregroundColor: foregroundColor ?? theme.appBarTheme.foregroundColor,
      elevation: elevation ?? theme.appBarTheme.elevation,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);

    switch (variant) {
      case CustomAppBarVariant.withSearch:
        return GestureDetector(
          onTap: onSearchTap,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withAlpha(26),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outline.withAlpha(77),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(
                  Icons.search,
                  size: 20,
                  color: theme.colorScheme.onSurface.withAlpha(153),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    searchHint ?? 'Search inspections...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(153),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      case CustomAppBarVariant.minimal:
        return Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        );
      default:
        return Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        );
    }
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;

    if (!automaticallyImplyLeading || !showBackButton) return null;

    final canPop = Navigator.of(context).canPop();
    if (!canPop) return null;

    return IconButton(
      icon: const Icon(Icons.arrow_back_ios, size: 20),
      onPressed: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop();
      },
      tooltip: 'Back',
    );
  }

  List<Widget>? _buildActions(BuildContext context) {
    final theme = Theme.of(context);
    List<Widget> actionWidgets = [];

    // Add variant-specific actions
    switch (variant) {
      case CustomAppBarVariant.withActions:
        actionWidgets.addAll([
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              HapticFeedback.lightImpact();
              // Navigate to notifications
            },
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              HapticFeedback.lightImpact();
              _showMoreMenu(context);
            },
            tooltip: 'More options',
          ),
        ]);
        break;
      case CustomAppBarVariant.standard:
        actionWidgets.add(
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, '/profile-settings-screen');
            },
            tooltip: 'Profile',
          ),
        );
        break;
      default:
        break;
    }

    // Add custom actions if provided
    if (actions != null) {
      actionWidgets.addAll(actions!);
    }

    return actionWidgets.isNotEmpty ? actionWidgets : null;
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile-settings-screen');
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help & Support'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to help
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                // Show about dialog
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

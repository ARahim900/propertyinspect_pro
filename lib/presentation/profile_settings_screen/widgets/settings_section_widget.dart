import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SettingsSectionWidget extends StatelessWidget {
  final String title;
  final List<SettingsItem> items;

  const SettingsSectionWidget({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 3.h, 4.w, 1.h),
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
              indent: 4.w,
              endIndent: 4.w,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildSettingsItem(context, item);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, SettingsItem item) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: item.onTap != null
          ? () {
              HapticFeedback.lightImpact();
              item.onTap!();
            }
          : null,
      borderRadius: BorderRadius.circular(3.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          children: [
            if (item.icon != null) ...[
              CustomIconWidget(
                iconName: item.icon!,
                size: 5.w,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              SizedBox(width: 3.w),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    SizedBox(height: 0.5.h),
                    Text(
                      item.subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (item.trailing != null) ...[
              SizedBox(width: 2.w),
              item.trailing!,
            ] else if (item.showDisclosure) ...[
              SizedBox(width: 2.w),
              CustomIconWidget(
                iconName: 'chevron_right',
                size: 4.w,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SettingsItem {
  final String title;
  final String? subtitle;
  final String? icon;
  final Widget? trailing;
  final bool showDisclosure;
  final VoidCallback? onTap;

  const SettingsItem({
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.showDisclosure = true,
    this.onTap,
  });
}

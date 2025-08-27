import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MetricCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final VoidCallback? onTap;
  final bool showTrend;
  final String? trendValue;
  final bool isPositiveTrend;

  const MetricCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.onTap,
    this.showTrend = false,
    this.trendValue,
    this.isPositiveTrend = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.lightImpact();
          onTap!();
        }
      },
      child: Container(
        width: 42.w,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: backgroundColor ?? theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(3.w),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomIconWidget(
                  iconName: _getIconName(icon),
                  color: iconColor ?? theme.colorScheme.primary,
                  size: 6.w,
                ),
                if (showTrend && trendValue != null)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: isPositiveTrend
                          ? AppTheme.lightTheme.colorScheme.tertiary
                              .withValues(alpha: 0.1)
                          : AppTheme.lightTheme.colorScheme.error
                              .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName:
                              isPositiveTrend ? 'trending_up' : 'trending_down',
                          color: isPositiveTrend
                              ? AppTheme.lightTheme.colorScheme.tertiary
                              : AppTheme.lightTheme.colorScheme.error,
                          size: 3.w,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          trendValue!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isPositiveTrend
                                ? AppTheme.lightTheme.colorScheme.tertiary
                                : AppTheme.lightTheme.colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _getIconName(IconData iconData) {
    if (iconData == Icons.schedule) return 'schedule';
    if (iconData == Icons.check_circle) return 'check_circle';
    if (iconData == Icons.receipt) return 'receipt';
    if (iconData == Icons.timer) return 'timer';
    if (iconData == Icons.assignment) return 'assignment';
    if (iconData == Icons.trending_up) return 'trending_up';
    if (iconData == Icons.trending_down) return 'trending_down';
    return 'dashboard';
  }
}

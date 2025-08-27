import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickActionsWidget extends StatelessWidget {
  final VoidCallback? onStartInspection;
  final VoidCallback? onViewSchedule;
  final VoidCallback? onCreateInvoice;
  final VoidCallback? onViewReports;

  const QuickActionsWidget({
    super.key,
    this.onStartInspection,
    this.onViewSchedule,
    this.onCreateInvoice,
    this.onViewReports,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  title: 'Start Inspection',
                  icon: Icons.play_circle_filled,
                  color: theme.colorScheme.primary,
                  onTap: onStartInspection,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildActionButton(
                  context,
                  title: 'View Schedule',
                  icon: Icons.calendar_today,
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                  onTap: onViewSchedule,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  title: 'Create Invoice',
                  icon: Icons.receipt_long,
                  color: AppTheme.warningLight,
                  onTap: onCreateInvoice,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildActionButton(
                  context,
                  title: 'View Reports',
                  icon: Icons.analytics,
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  onTap: onViewReports,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.lightImpact();
          onTap();
        }
      },
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(3.w),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: _getIconName(icon),
              color: color,
              size: 8.w,
            ),
            SizedBox(height: 1.h),
            Text(
              title,
              style: theme.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _getIconName(IconData iconData) {
    if (iconData == Icons.play_circle_filled) return 'play_circle_filled';
    if (iconData == Icons.calendar_today) return 'calendar_today';
    if (iconData == Icons.receipt_long) return 'receipt_long';
    if (iconData == Icons.analytics) return 'analytics';
    return 'dashboard';
  }
}

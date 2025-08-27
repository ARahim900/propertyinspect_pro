import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ActivityItemWidget extends StatelessWidget {
  final Map<String, dynamic> activity;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ActivityItemWidget({
    super.key,
    required this.activity,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String type = activity['type'] as String;
    final String title = activity['title'] as String;
    final String description = activity['description'] as String;
    final DateTime timestamp = activity['timestamp'] as DateTime;
    final String status = activity['status'] as String? ?? '';

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.lightImpact();
          onTap!();
        }
      },
      onLongPress: () {
        if (onLongPress != null) {
          HapticFeedback.mediumImpact();
          onLongPress!();
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(3.w),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: _getActivityColor(type, theme).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: _getActivityIcon(type),
                  color: _getActivityColor(type, theme),
                  size: 5.w,
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (status.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status, theme)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(1.5.w),
                          ),
                          child: Text(
                            status,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: _getStatusColor(status, theme),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    _formatTimestamp(timestamp),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getActivityColor(String type, ThemeData theme) {
    switch (type.toLowerCase()) {
      case 'inspection':
        return theme.colorScheme.primary;
      case 'schedule':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'invoice':
        return AppTheme.warningLight;
      case 'completion':
        return AppTheme.lightTheme.colorScheme.tertiary;
      default:
        return theme.colorScheme.secondary;
    }
  }

  String _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'inspection':
        return 'assignment';
      case 'schedule':
        return 'schedule';
      case 'invoice':
        return 'receipt';
      case 'completion':
        return 'check_circle';
      default:
        return 'notifications';
    }
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'paid':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'pending':
      case 'scheduled':
        return AppTheme.warningLight;
      case 'overdue':
      case 'failed':
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return theme.colorScheme.primary;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
    }
  }
}

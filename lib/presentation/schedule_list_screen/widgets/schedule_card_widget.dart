import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../core/layout_constants.dart';

class ScheduleCardWidget extends StatelessWidget {
  final Map<String, dynamic> schedule;
  final VoidCallback? onTap;
  final VoidCallback? onCallClient;
  final VoidCallback? onGetDirections;
  final VoidCallback? onReschedule;
  final VoidCallback? onMarkComplete;
  final VoidCallback? onCancel;

  const ScheduleCardWidget({
    super.key,
    required this.schedule,
    this.onTap,
    this.onCallClient,
    this.onGetDirections,
    this.onReschedule,
    this.onMarkComplete,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = schedule['status'] as String? ?? 'scheduled';
    final statusColor = _getStatusColor(status, theme);

    return Dismissible(
      key: Key('schedule_${schedule['id']}'),
      background: _buildSwipeBackground(context, isLeft: false),
      secondaryBackground: _buildSwipeBackground(context, isLeft: true),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          // Swipe right - Quick actions
          _showQuickActions(context);
        } else {
          // Swipe left - Complete/Cancel actions
          _showCompleteActions(context);
        }
      },
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LayoutConstants.radiusLg),
        ),
        child: InkWell(
          onTap: onTap,
          onLongPress: () => _showContextMenu(context),
          borderRadius: BorderRadius.circular(LayoutConstants.radiusLg),
          child: Padding(
            padding: EdgeInsets.all(LayoutConstants.paddingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with icon, client info, and status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CustomIconWidget(
                        iconName: _getPropertyTypeIcon(
                            schedule['propertyType'] as String? ??
                                'residential'),
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            schedule['clientName'] as String? ??
                                'Unknown Client',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            schedule['propertyAddress'] as String? ??
                                'No address provided',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                              fontSize: 14,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Time and duration info
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'access_time',
                        color: theme.colorScheme.primary,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        schedule['scheduledTime'] as String? ?? 'Time not set',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Spacer(),
                      CustomIconWidget(
                        iconName: 'timer',
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        '${schedule['estimatedDuration'] ?? 60} min',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Notes section (if present)
                if (schedule['notes'] != null &&
                    (schedule['notes'] as String).isNotEmpty) ...[
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomIconWidget(
                          iconName: 'note',
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            schedule['notes'] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(BuildContext context, {required bool isLeft}) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isLeft ? AppTheme.errorLight : theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Align(
        alignment: isLeft ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: isLeft
                ? [
                    CustomIconWidget(
                      iconName: 'check_circle',
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Complete',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ]
                : [
                    CustomIconWidget(
                      iconName: 'phone',
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Call',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
          ),
        ),
      ),
    );
  }

  void _showQuickActions(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'phone',
                color: AppTheme.successLight,
                size: 24,
              ),
              title: Text('Call Client'),
              onTap: () {
                Navigator.pop(context);
                onCallClient?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'directions',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: Text('Get Directions'),
              onTap: () {
                Navigator.pop(context);
                onGetDirections?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'schedule',
                color: AppTheme.warningLight,
                size: 24,
              ),
              title: Text('Reschedule'),
              onTap: () {
                Navigator.pop(context);
                onReschedule?.call();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCompleteActions(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.successLight,
                size: 24,
              ),
              title: Text('Mark Complete'),
              onTap: () {
                Navigator.pop(context);
                _showConfirmDialog(
                    context,
                    'Mark Complete',
                    'Are you sure you want to mark this inspection as complete?',
                    onMarkComplete);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'cancel',
                color: AppTheme.errorLight,
                size: 24,
              ),
              title: Text('Cancel Inspection'),
              onTap: () {
                Navigator.pop(context);
                _showConfirmDialog(
                    context,
                    'Cancel Inspection',
                    'Are you sure you want to cancel this inspection?',
                    onCancel);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'edit',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: Text('Edit Details'),
              onTap: () {
                Navigator.pop(context);
                // Handle edit
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'content_copy',
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
                size: 24,
              ),
              title: Text('Duplicate'),
              onTap: () {
                Navigator.pop(context);
                // Handle duplicate
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
                size: 24,
              ),
              title: Text('Share with Team'),
              onTap: () {
                Navigator.pop(context);
                // Handle share
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, String title, String message,
      VoidCallback? onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm?.call();
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppTheme.successLight;
      case 'in_progress':
        return AppTheme.warningLight;
      case 'cancelled':
        return AppTheme.errorLight;
      case 'scheduled':
      default:
        return theme.colorScheme.primary;
    }
  }

  String _getPropertyTypeIcon(String propertyType) {
    switch (propertyType.toLowerCase()) {
      case 'commercial':
        return 'business';
      case 'industrial':
        return 'factory';
      case 'apartment':
        return 'apartment';
      case 'residential':
      default:
        return 'home';
    }
  }
}

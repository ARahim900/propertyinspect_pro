import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SyncStatusWidget extends StatelessWidget {
  final DateTime? lastSyncTime;
  final bool isSyncing;
  final VoidCallback? onManualSync;

  const SyncStatusWidget({
    super.key,
    this.lastSyncTime,
    this.isSyncing = false,
    this.onManualSync,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: _getSyncStatusColor(theme),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: _getSyncStatusColor(theme).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: isSyncing ? 'sync' : 'cloud_done',
                  size: 4.w,
                  color: _getSyncStatusColor(theme),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Sync Status',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      _getSyncStatusText(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (lastSyncTime != null) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(2.w),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'access_time',
                    size: 3.w,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Last sync: ${_formatSyncTime(lastSyncTime!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isSyncing
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      if (onManualSync != null) onManualSync!();
                    },
              icon: isSyncing
                  ? SizedBox(
                      width: 4.w,
                      height: 4.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : CustomIconWidget(
                      iconName: 'sync',
                      size: 4.w,
                      color: Colors.white,
                    ),
              label: Text(
                isSyncing ? 'Syncing...' : 'Sync Now',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.w),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSyncStatusColor(ThemeData theme) {
    if (isSyncing) {
      return theme.colorScheme.primary;
    }
    if (lastSyncTime != null) {
      final timeDiff = DateTime.now().difference(lastSyncTime!);
      if (timeDiff.inHours < 1) {
        return AppTheme.lightTheme.colorScheme.tertiary; // Success color
      } else if (timeDiff.inHours < 24) {
        return Color(0xFFD97706); // Warning color
      } else {
        return theme.colorScheme.error;
      }
    }
    return theme.colorScheme.error;
  }

  String _getSyncStatusText() {
    if (isSyncing) {
      return 'Syncing data with server...';
    }
    if (lastSyncTime != null) {
      final timeDiff = DateTime.now().difference(lastSyncTime!);
      if (timeDiff.inHours < 1) {
        return 'All data is up to date';
      } else if (timeDiff.inHours < 24) {
        return 'Data sync recommended';
      } else {
        return 'Data sync required';
      }
    }
    return 'Never synced';
  }

  String _formatSyncTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}

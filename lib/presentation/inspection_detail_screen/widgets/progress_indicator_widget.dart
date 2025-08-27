import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/responsive_helper.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final double progress;
  final int completedItems;
  final int totalItems;

  const ProgressIndicatorWidget({
    super.key,
    required this.progress,
    required this.completedItems,
    required this.totalItems,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressPercentage = (progress * 100).round();

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getSpacing(context, small: 16),
        vertical: ResponsiveHelper.getSpacing(context, small: 8),
      ),
      padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, small: 16)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
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
        children: [
          // Progress header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textDirection: TextDirection.ltr,
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getSpacing(context, small: 8),
                  vertical: ResponsiveHelper.getSpacing(context, small: 4),
                ),
                decoration: BoxDecoration(
                  color: _getProgressColor(progress).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$progressPercentage%',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: _getProgressColor(progress),
                    fontWeight: FontWeight.w600,
                  ),
                  textDirection: TextDirection.ltr,
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveHelper.getSpacing(context, small: 12)),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor:
                  AlwaysStoppedAnimation<Color>(_getProgressColor(progress)),
              minHeight: 8,
            ),
          ),

          SizedBox(height: ResponsiveHelper.getSpacing(context, small: 12)),

          // Progress details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildProgressStat(
                  context,
                  'Completed',
                  completedItems.toString(),
                  AppTheme.successLight,
                  Icons.check_circle,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildProgressStat(
                  context,
                  'Remaining',
                  (totalItems - completedItems).toString(),
                  AppTheme.warningLight,
                  Icons.pending,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildProgressStat(
                  context,
                  'Total',
                  totalItems.toString(),
                  theme.colorScheme.primary,
                  Icons.assignment,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: ResponsiveHelper.getIconSize(context, small: 20),
        ),
        SizedBox(height: ResponsiveHelper.getSpacing(context, small: 4)),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textDirection: TextDirection.ltr,
        ),
      ],
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return AppTheme.successLight;
    if (progress >= 0.5) return AppTheme.warningLight;
    return AppTheme.errorLight;
  }
}

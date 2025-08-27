import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

enum InvoiceStatus { draft, sent, paid }

class InvoiceStatusWidget extends StatelessWidget {
  final InvoiceStatus currentStatus;
  final Function(InvoiceStatus) onStatusChanged;
  final DateTime? sentDate;
  final DateTime? paidDate;

  const InvoiceStatusWidget({
    super.key,
    required this.currentStatus,
    required this.onStatusChanged,
    this.sentDate,
    this.paidDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'assignment_turned_in',
                color: theme.colorScheme.primary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Invoice Status',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: InvoiceStatus.values.map((status) {
              final isSelected = status == currentStatus;
              final isFirst = status == InvoiceStatus.draft;
              final isLast = status == InvoiceStatus.paid;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onStatusChanged(status),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _getStatusColor(status, theme)
                          : Colors.transparent,
                      borderRadius: BorderRadius.horizontal(
                        left: isFirst ? const Radius.circular(8) : Radius.zero,
                        right: isLast ? const Radius.circular(8) : Radius.zero,
                      ),
                      border: Border.all(
                        color: isSelected
                            ? _getStatusColor(status, theme)
                            : theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        CustomIconWidget(
                          iconName: _getStatusIcon(status),
                          color: isSelected
                              ? Colors.white
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                          size: 5.w,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          _getStatusLabel(status),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isSelected
                                ? Colors.white
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
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
          if (_getStatusDate() != null) ...[
            SizedBox(height: 2.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: _getStatusColor(currentStatus, theme)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'schedule',
                    color: _getStatusColor(currentStatus, theme),
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    '${_getStatusActionLabel(currentStatus)}: ${_formatDate(_getStatusDate()!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getStatusColor(currentStatus, theme),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(InvoiceStatus status, ThemeData theme) {
    switch (status) {
      case InvoiceStatus.draft:
        return theme.colorScheme.secondary;
      case InvoiceStatus.sent:
        return AppTheme.warningLight;
      case InvoiceStatus.paid:
        return AppTheme.successLight;
    }
  }

  String _getStatusIcon(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return 'edit';
      case InvoiceStatus.sent:
        return 'send';
      case InvoiceStatus.paid:
        return 'check_circle';
    }
  }

  String _getStatusLabel(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.sent:
        return 'Sent';
      case InvoiceStatus.paid:
        return 'Paid';
    }
  }

  String _getStatusActionLabel(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return 'Created';
      case InvoiceStatus.sent:
        return 'Sent';
      case InvoiceStatus.paid:
        return 'Paid';
    }
  }

  DateTime? _getStatusDate() {
    switch (currentStatus) {
      case InvoiceStatus.draft:
        return DateTime.now();
      case InvoiceStatus.sent:
        return sentDate;
      case InvoiceStatus.paid:
        return paidDate;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }
}

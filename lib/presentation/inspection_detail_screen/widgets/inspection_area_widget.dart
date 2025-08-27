import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './inspection_item_widget.dart';

class InspectionAreaWidget extends StatefulWidget {
  final Map<String, dynamic> areaData;
  final Function(String, String, String) onItemStatusChanged;
  final Function(String, String, String) onCommentChanged;
  final Function(String, String) onPhotoAdded;

  const InspectionAreaWidget({
    super.key,
    required this.areaData,
    required this.onItemStatusChanged,
    required this.onCommentChanged,
    required this.onPhotoAdded,
  });

  @override
  State<InspectionAreaWidget> createState() => _InspectionAreaWidgetState();
}

class _InspectionAreaWidgetState extends State<InspectionAreaWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = (widget.areaData['items'] as List?) ?? [];
    final completedItems = items
        .where((item) =>
            (item as Map<String, dynamic>)['status'] != null &&
            (item)['status'] != 'pending')
        .length;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.w),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12.w),
            child: Container(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.w),
                    ),
                    child: CustomIconWidget(
                      iconName: widget.areaData['icon'] as String? ?? 'home',
                      color: theme.colorScheme.primary,
                      size: 20.w,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.areaData['name'] as String? ?? 'Area Name',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '$completedItems of ${items.length} items completed',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: completedItems == items.length && items.isNotEmpty
                          ? AppTheme.successLight.withValues(alpha: 0.1)
                          : theme.colorScheme.outline.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16.w),
                    ),
                    child: CustomIconWidget(
                      iconName:
                          completedItems == items.length && items.isNotEmpty
                              ? 'check_circle'
                              : 'radio_button_unchecked',
                      color: completedItems == items.length && items.isNotEmpty
                          ? AppTheme.successLight
                          : theme.colorScheme.outline,
                      size: 18.w,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: CustomIconWidget(
                      iconName: 'keyboard_arrow_down',
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 24.w,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isExpanded ? null : 0,
            child: _isExpanded
                ? Column(
                    children: [
                      Container(
                        height: 1,
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                        margin: EdgeInsets.symmetric(horizontal: 16.w),
                      ),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.all(16.w),
                        itemCount: items.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          final item = items[index] as Map<String, dynamic>;
                          return InspectionItemWidget(
                            itemData: item,
                            areaId: widget.areaData['id'] as String? ?? '',
                            onStatusChanged: (status) =>
                                widget.onItemStatusChanged(
                              widget.areaData['id'] as String? ?? '',
                              item['id'] as String? ?? '',
                              status,
                            ),
                            onCommentChanged: (comment) =>
                                widget.onCommentChanged(
                              widget.areaData['id'] as String? ?? '',
                              item['id'] as String? ?? '',
                              comment,
                            ),
                            onPhotoAdded: () => widget.onPhotoAdded(
                              widget.areaData['id'] as String? ?? '',
                              item['id'] as String? ?? '',
                            ),
                          );
                        },
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

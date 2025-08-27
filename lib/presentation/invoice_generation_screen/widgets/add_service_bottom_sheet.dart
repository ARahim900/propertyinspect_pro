import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class AddServiceBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onServiceAdded;

  const AddServiceBottomSheet({
    super.key,
    required this.onServiceAdded,
  });

  @override
  State<AddServiceBottomSheet> createState() => _AddServiceBottomSheetState();
}

class _AddServiceBottomSheetState extends State<AddServiceBottomSheet> {
  final List<Map<String, dynamic>> _serviceTemplates = [
    {
      'id': 1,
      'name': 'Basic Property Inspection',
      'description':
          'Comprehensive property inspection including structural, electrical, and plumbing assessment',
      'rate': 150.0,
      'unit': 'per property',
    },
    {
      'id': 2,
      'name': 'Electrical System Inspection',
      'description':
          'Detailed electrical system inspection and safety assessment',
      'rate': 75.0,
      'unit': 'per hour',
    },
    {
      'id': 3,
      'name': 'Plumbing System Inspection',
      'description': 'Complete plumbing system inspection and leak detection',
      'rate': 85.0,
      'unit': 'per hour',
    },
    {
      'id': 4,
      'name': 'HVAC System Inspection',
      'description':
          'Heating, ventilation, and air conditioning system inspection',
      'rate': 95.0,
      'unit': 'per hour',
    },
    {
      'id': 5,
      'name': 'Roof Inspection',
      'description':
          'Comprehensive roof condition assessment and damage evaluation',
      'rate': 125.0,
      'unit': 'per property',
    },
    {
      'id': 6,
      'name': 'Foundation Inspection',
      'description':
          'Structural foundation inspection and stability assessment',
      'rate': 110.0,
      'unit': 'per property',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.only(top: 1.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Add Service',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: theme.colorScheme.onSurface,
                    size: 6.w,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: _serviceTemplates.length + 1,
              separatorBuilder: (context, index) => SizedBox(height: 1.h),
              itemBuilder: (context, index) {
                if (index == _serviceTemplates.length) {
                  return _buildCustomServiceTile(context);
                }

                final service = _serviceTemplates[index];
                return _buildServiceTemplateTile(context, service);
              },
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildServiceTemplateTile(
      BuildContext context, Map<String, dynamic> service) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        final newService = {
          'id': DateTime.now().millisecondsSinceEpoch,
          'description': service['description'] as String,
          'quantity': 1.0,
          'rate': service['rate'] as double,
          'subtotal': service['rate'] as double,
        };

        widget.onServiceAdded(newService);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    service['name'] as String,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '\$${(service['rate'] as double).toStringAsFixed(2)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              service['description'] as String,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 0.5.h),
            Text(
              service['unit'] as String,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomServiceTile(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        final newService = {
          'id': DateTime.now().millisecondsSinceEpoch,
          'description': '',
          'quantity': 1.0,
          'rate': 0.0,
          'subtotal': 0.0,
        };

        widget.onServiceAdded(newService);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'add',
                  color: Colors.white,
                  size: 6.w,
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Custom Service',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'Add a custom service with your own description and rate',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'arrow_forward_ios',
              color: theme.colorScheme.primary,
              size: 4.w,
            ),
          ],
        ),
      ),
    );
  }
}

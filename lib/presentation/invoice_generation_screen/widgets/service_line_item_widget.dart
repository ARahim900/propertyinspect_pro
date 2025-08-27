import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ServiceLineItemWidget extends StatefulWidget {
  final Map<String, dynamic> serviceData;
  final Function(Map<String, dynamic>) onServiceUpdated;
  final VoidCallback onRemove;

  const ServiceLineItemWidget({
    super.key,
    required this.serviceData,
    required this.onServiceUpdated,
    required this.onRemove,
  });

  @override
  State<ServiceLineItemWidget> createState() => _ServiceLineItemWidgetState();
}

class _ServiceLineItemWidgetState extends State<ServiceLineItemWidget> {
  late TextEditingController _descriptionController;
  late TextEditingController _quantityController;
  late TextEditingController _rateController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.serviceData['description'] as String? ?? '',
    );
    _quantityController = TextEditingController(
      text: (widget.serviceData['quantity'] as num? ?? 1).toString(),
    );
    _rateController = TextEditingController(
      text: (widget.serviceData['rate'] as num? ?? 0.0).toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _quantityController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _updateService() {
    final quantity = double.tryParse(_quantityController.text) ?? 1.0;
    final rate = double.tryParse(_rateController.text) ?? 0.0;
    final subtotal = quantity * rate;

    final updatedService = {
      ...widget.serviceData,
      'description': _descriptionController.text,
      'quantity': quantity,
      'rate': rate,
      'subtotal': subtotal,
    };

    widget.onServiceUpdated(updatedService);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quantity = double.tryParse(_quantityController.text) ?? 1.0;
    final rate = double.tryParse(_rateController.text) ?? 0.0;
    final subtotal = quantity * rate;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
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
              Expanded(
                child: Text(
                  'Service Description',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: widget.onRemove,
                icon: CustomIconWidget(
                  iconName: 'delete_outline',
                  color: theme.colorScheme.error,
                  size: 5.w,
                ),
                constraints: BoxConstraints(
                  minWidth: 8.w,
                  minHeight: 8.w,
                ),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          SizedBox(height: 1.h),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              hintText: 'Enter service description',
              contentPadding: EdgeInsets.symmetric(
                horizontal: 3.w,
                vertical: 1.5.h,
              ),
            ),
            maxLines: 2,
            onChanged: (_) => _updateService(),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quantity',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        hintText: '1.0',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.5.h,
                        ),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*')),
                      ],
                      onChanged: (_) => _updateService(),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rate (\$)',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    TextFormField(
                      controller: _rateController,
                      decoration: InputDecoration(
                        hintText: '0.00',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.5.h,
                        ),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      onChanged: (_) => _updateService(),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subtotal',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        '\$${subtotal.toStringAsFixed(2)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

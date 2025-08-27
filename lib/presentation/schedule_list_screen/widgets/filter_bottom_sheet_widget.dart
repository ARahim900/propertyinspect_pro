import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFiltersApplied;

  const FilterBottomSheetWidget({
    super.key,
    required this.currentFilters,
    required this.onFiltersApplied,
  });

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late Map<String, dynamic> _tempFilters;
  DateTimeRange? _selectedDateRange;
  String? _selectedPropertyType;
  List<String> _selectedStatuses = [];

  final List<String> _propertyTypes = [
    'Residential',
    'Commercial',
    'Industrial',
    'Apartment',
  ];

  final List<Map<String, dynamic>> _statusOptions = [
    {
      'value': 'scheduled',
      'label': 'Scheduled',
      'color': AppTheme.primaryLight
    },
    {
      'value': 'in_progress',
      'label': 'In Progress',
      'color': AppTheme.warningLight
    },
    {
      'value': 'completed',
      'label': 'Completed',
      'color': AppTheme.successLight
    },
    {'value': 'cancelled', 'label': 'Cancelled', 'color': AppTheme.errorLight},
  ];

  @override
  void initState() {
    super.initState();
    _tempFilters = Map.from(widget.currentFilters);
    _initializeFilters();
  }

  void _initializeFilters() {
    // Initialize date range
    if (_tempFilters['dateRange'] != null) {
      final dateRange = _tempFilters['dateRange'] as Map<String, DateTime>;
      _selectedDateRange = DateTimeRange(
        start: dateRange['start']!,
        end: dateRange['end']!,
      );
    }

    // Initialize property type
    _selectedPropertyType = _tempFilters['propertyType'] as String?;

    // Initialize statuses
    if (_tempFilters['statuses'] != null) {
      _selectedStatuses = List<String>.from(_tempFilters['statuses'] as List);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(theme),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateRangeSection(theme),
                  SizedBox(height: 3.h),
                  _buildPropertyTypeSection(theme),
                  SizedBox(height: 3.h),
                  _buildStatusSection(theme),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
          _buildActionButtons(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Filter Inspections',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: CustomIconWidget(
              iconName: 'close',
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        InkWell(
          onTap: _selectDateRange,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'date_range',
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    _selectedDateRange != null
                        ? '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}'
                        : 'Select date range',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _selectedDateRange != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                CustomIconWidget(
                  iconName: 'chevron_right',
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (_selectedDateRange != null) ...[
          SizedBox(height: 1.h),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedDateRange = null;
                  });
                },
                child: Text(
                  'Clear',
                  style: TextStyle(color: AppTheme.errorLight),
                ),
              ),
              Spacer(),
              _buildQuickDateButton(theme, 'This Week', _getThisWeekRange()),
              SizedBox(width: 2.w),
              _buildQuickDateButton(theme, 'This Month', _getThisMonthRange()),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildQuickDateButton(
      ThemeData theme, String label, DateTimeRange range) {
    return TextButton(
      onPressed: () {
        setState(() {
          _selectedDateRange = range;
        });
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPropertyTypeSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Property Type',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: [
            _buildPropertyTypeChip(theme, null, 'All Types'),
            ..._propertyTypes
                .map((type) => _buildPropertyTypeChip(theme, type, type)),
          ],
        ),
      ],
    );
  }

  Widget _buildPropertyTypeChip(ThemeData theme, String? value, String label) {
    final isSelected = _selectedPropertyType == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedPropertyType = selected ? value : null;
        });
      },
      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
      side: BorderSide(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.outline.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildStatusSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Column(
          children: _statusOptions.map((status) {
            final isSelected = _selectedStatuses.contains(status['value']);

            return CheckboxListTile(
              value: isSelected,
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _selectedStatuses.add(status['value']);
                  } else {
                    _selectedStatuses.remove(status['value']);
                  }
                });
              },
              title: Row(
                children: [
                  Container(
                    width: 3.w,
                    height: 3.w,
                    decoration: BoxDecoration(
                      color: status['color'],
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    status['label'],
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              dense: true,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _clearAllFilters,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
              ),
              child: Text('Clear All'),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
              ),
              child: Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  void _selectDateRange() async {
    HapticFeedback.lightImpact();

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.primaryLight,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _clearAllFilters() {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedDateRange = null;
      _selectedPropertyType = null;
      _selectedStatuses.clear();
    });
  }

  void _applyFilters() {
    HapticFeedback.lightImpact();

    final filters = <String, dynamic>{};

    if (_selectedDateRange != null) {
      filters['dateRange'] = {
        'start': _selectedDateRange!.start,
        'end': _selectedDateRange!.end,
      };
    }

    if (_selectedPropertyType != null) {
      filters['propertyType'] = _selectedPropertyType;
    }

    if (_selectedStatuses.isNotEmpty) {
      filters['statuses'] = _selectedStatuses;
    }

    widget.onFiltersApplied(filters);
    Navigator.pop(context);
  }

  DateTimeRange _getThisWeekRange() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));
    return DateTimeRange(start: startOfWeek, end: endOfWeek);
  }

  DateTimeRange _getThisMonthRange() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    return DateTimeRange(start: startOfMonth, end: endOfMonth);
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

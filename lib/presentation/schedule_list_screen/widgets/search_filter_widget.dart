import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchFilterWidget extends StatefulWidget {
  final String searchQuery;
  final Function(String) onSearchChanged;
  final VoidCallback onFilterTap;
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;
  final Map<String, dynamic> activeFilters;

  const SearchFilterWidget({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onFilterTap,
    required this.isCollapsed,
    required this.onToggleCollapse,
    required this.activeFilters,
  });

  @override
  State<SearchFilterWidget> createState() => _SearchFilterWidgetState();
}

class _SearchFilterWidgetState extends State<SearchFilterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _searchController.text = widget.searchQuery;

    if (!widget.isCollapsed) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SearchFilterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCollapsed != oldWidget.isCollapsed) {
      if (widget.isCollapsed) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        _buildToggleButton(theme),
        SizeTransition(
          sizeFactor: _animation,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Column(
              children: [
                _buildSearchBar(theme),
                SizedBox(height: 2.h),
                _buildFilterSection(theme),
                if (_hasActiveFilters()) ...[
                  SizedBox(height: 2.h),
                  _buildActiveFilters(theme),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onToggleCollapse();
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'search',
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      widget.isCollapsed ? 'Search & Filter' : 'Hide Search',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    AnimatedRotation(
                      turns: widget.isCollapsed ? 0 : 0.5,
                      duration: Duration(milliseconds: 300),
                      child: CustomIconWidget(
                        iconName: 'expand_more',
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return TextField(
      controller: _searchController,
      onChanged: widget.onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Search by client name or property address...',
        prefixIcon: Padding(
          padding: EdgeInsets.all(3.w),
          child: CustomIconWidget(
            iconName: 'search',
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            size: 20,
          ),
        ),
        suffixIcon: widget.searchQuery.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                  widget.onSearchChanged('');
                },
                icon: CustomIconWidget(
                  iconName: 'clear',
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 20,
                ),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              widget.onFilterTap();
            },
            icon: CustomIconWidget(
              iconName: 'filter_list',
              color: Colors.white,
              size: 20,
            ),
            label: Text('Filters'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        if (_hasActiveFilters()) ...[
          SizedBox(width: 3.w),
          TextButton(
            onPressed: _clearAllFilters,
            child: Text(
              'Clear All',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppTheme.errorLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActiveFilters(ThemeData theme) {
    final filters = <Widget>[];

    // Date range filter
    if (widget.activeFilters['dateRange'] != null) {
      final dateRange =
          widget.activeFilters['dateRange'] as Map<String, DateTime>;
      filters.add(_buildFilterChip(
        theme,
        'Date: ${_formatDateRange(dateRange)}',
        () => _removeFilter('dateRange'),
      ));
    }

    // Property type filter
    if (widget.activeFilters['propertyType'] != null) {
      filters.add(_buildFilterChip(
        theme,
        'Type: ${widget.activeFilters['propertyType']}',
        () => _removeFilter('propertyType'),
      ));
    }

    // Status filters
    if (widget.activeFilters['statuses'] != null) {
      final statuses = widget.activeFilters['statuses'] as List<String>;
      if (statuses.isNotEmpty) {
        filters.add(_buildFilterChip(
          theme,
          'Status: ${statuses.join(', ')}',
          () => _removeFilter('statuses'),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Filters:',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: filters,
        ),
      ],
    );
  }

  Widget _buildFilterChip(
      ThemeData theme, String label, VoidCallback onRemove) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 2.w),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onRemove();
            },
            child: CustomIconWidget(
              iconName: 'close',
              color: theme.colorScheme.primary,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return widget.activeFilters.isNotEmpty &&
        widget.activeFilters.values.any((value) {
          if (value is List) return value.isNotEmpty;
          return value != null;
        });
  }

  void _removeFilter(String key) {
    // This would be handled by the parent widget
    // For now, just provide haptic feedback
    HapticFeedback.lightImpact();
  }

  void _clearAllFilters() {
    HapticFeedback.mediumImpact();
    // This would be handled by the parent widget
  }

  String _formatDateRange(Map<String, DateTime> dateRange) {
    final start = dateRange['start'];
    final end = dateRange['end'];

    if (start == null || end == null) return 'Invalid range';

    final startStr = '${start.month}/${start.day}';
    final endStr = '${end.month}/${end.day}';

    return '$startStr - $endStr';
  }
}

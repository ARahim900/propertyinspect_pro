import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/layout_constants.dart';
import '../../utils/responsive_helper.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_tab_bar.dart';
import './widgets/calendar_view_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/schedule_card_widget.dart';
import './widgets/search_filter_widget.dart';

class ScheduleListScreen extends StatefulWidget {
  const ScheduleListScreen({super.key});

  @override
  State<ScheduleListScreen> createState() => _ScheduleListScreenState();
}

class _ScheduleListScreenState extends State<ScheduleListScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  // State variables
  bool _isSearchCollapsed = true;
  String _searchQuery = '';
  Map<String, dynamic> _activeFilters = {};
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _isOffline = false;

  // Mock data
  final List<Map<String, dynamic>> _allSchedules = [
    {
      "id": 1,
      "clientName": "Sarah Johnson",
      "propertyAddress": "123 Oak Street, Springfield, IL 62701",
      "propertyType": "residential",
      "scheduledDate": "2025-08-27",
      "scheduledTime": "9:00 AM",
      "estimatedDuration": 90,
      "status": "scheduled",
      "notes":
          "Client prefers morning appointments. Check HVAC system thoroughly.",
      "clientPhone": "+1 (555) 123-4567",
      "inspectorId": "inspector_001"
    },
    {
      "id": 2,
      "clientName": "Metro Properties LLC",
      "propertyAddress": "456 Business Park Drive, Chicago, IL 60601",
      "propertyType": "commercial",
      "scheduledDate": "2025-08-27",
      "scheduledTime": "2:00 PM",
      "estimatedDuration": 120,
      "status": "in_progress",
      "notes":
          "Large office building inspection. Focus on fire safety systems.",
      "clientPhone": "+1 (555) 987-6543",
      "inspectorId": "inspector_002"
    },
    {
      "id": 3,
      "clientName": "David Chen",
      "propertyAddress": "789 Maple Avenue, Apartment 4B, Boston, MA 02101",
      "propertyType": "apartment",
      "scheduledDate": "2025-08-28",
      "scheduledTime": "10:30 AM",
      "estimatedDuration": 60,
      "status": "scheduled",
      "notes": "Pre-purchase inspection for condo unit.",
      "clientPhone": "+1 (555) 456-7890",
      "inspectorId": "inspector_001"
    },
    {
      "id": 4,
      "clientName": "Industrial Solutions Inc",
      "propertyAddress": "321 Factory Road, Detroit, MI 48201",
      "propertyType": "industrial",
      "scheduledDate": "2025-08-28",
      "scheduledTime": "8:00 AM",
      "estimatedDuration": 180,
      "status": "completed",
      "notes": "Annual safety compliance inspection completed successfully.",
      "clientPhone": "+1 (555) 321-0987",
      "inspectorId": "inspector_003"
    },
    {
      "id": 5,
      "clientName": "Emily Rodriguez",
      "propertyAddress": "654 Pine Street, Austin, TX 73301",
      "propertyType": "residential",
      "scheduledDate": "2025-08-29",
      "scheduledTime": "11:00 AM",
      "estimatedDuration": 75,
      "status": "scheduled",
      "notes": "First-time homebuyer inspection. Explain process thoroughly.",
      "clientPhone": "+1 (555) 654-3210",
      "inspectorId": "inspector_001"
    },
    {
      "id": 6,
      "clientName": "Riverside Apartments",
      "propertyAddress": "987 River View Complex, Portland, OR 97201",
      "propertyType": "apartment",
      "scheduledDate": "2025-08-29",
      "scheduledTime": "3:30 PM",
      "estimatedDuration": 45,
      "status": "cancelled",
      "notes": "Inspection cancelled due to tenant unavailability.",
      "clientPhone": "+1 (555) 789-0123",
      "inspectorId": "inspector_002"
    }
  ];

  List<Map<String, dynamic>> _filteredSchedules = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _filteredSchedules = List.from(_allSchedules);
    _setupScrollListener();
    _checkConnectivity();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.offset > 100 && !_isSearchCollapsed) {
        setState(() {
          _isSearchCollapsed = true;
        });
      }
    });
  }

  void _checkConnectivity() {
    // Simulate connectivity check
    setState(() {
      _isOffline = false; // Mock online state
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme),
      body: Column(
        children: [
          _buildTabBar(theme),
          SearchFilterWidget(
            searchQuery: _searchQuery,
            onSearchChanged: _handleSearchChanged,
            onFilterTap: _showFilterBottomSheet,
            isCollapsed: _isSearchCollapsed,
            onToggleCollapse: () {
              setState(() {
                _isSearchCollapsed = !_isSearchCollapsed;
              });
            },
            activeFilters: _activeFilters,
          ),
          if (_isOffline) _buildOfflineIndicator(theme),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildListView(theme),
                _buildCalendarView(theme),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(theme),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 1, // Schedules tab
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamedAndRemoveUntil(
                  context, '/dashboard-screen', (route) => false);
              break;
            case 2:
              Navigator.pushNamedAndRemoveUntil(
                  context, '/inspection-detail-screen', (route) => false);
              break;
            case 3:
              Navigator.pushNamedAndRemoveUntil(
                  context, '/invoice-generation-screen', (route) => false);
              break;
          }
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return CustomAppBar(
      title: 'Schedules',
      variant: CustomAppBarVariant.withActions,
      actions: [
        IconButton(
          onPressed: _refreshSchedules,
          icon: CustomIconWidget(
            iconName: 'refresh',
            color: theme.appBarTheme.foregroundColor ??
                theme.colorScheme.onSurface,
            size: 24,
          ),
          tooltip: 'Refresh',
        ),
        IconButton(
          onPressed: () =>
              Navigator.pushNamed(context, '/profile-settings-screen'),
          icon: CustomIconWidget(
            iconName: 'account_circle_outlined',
            color: theme.appBarTheme.foregroundColor ??
                theme.colorScheme.onSurface,
            size: 24,
          ),
          tooltip: 'Profile',
        ),
      ],
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return CustomTabBar(
      tabs: [
        CustomTab(label: 'List', icon: Icons.list),
        CustomTab(label: 'Calendar', icon: Icons.calendar_month),
      ],
      currentIndex: _tabController.index,
      onTap: (index) {
        _tabController.animateTo(index);
      },
      variant: CustomTabBarVariant.segmented,
    );
  }

  Widget _buildOfflineIndicator(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 1.h),
      color: AppTheme.warningLight.withValues(alpha: 0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'wifi_off',
            color: AppTheme.warningLight,
            size: 16,
          ),
          SizedBox(width: 2.w),
          Text(
            'Offline mode - Showing cached data',
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppTheme.warningLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(ThemeData theme) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: theme.colorScheme.primary,
        ),
      );
    }

    if (_filteredSchedules.isEmpty) {
      return _buildEmptyState(theme);
    }

    return RefreshIndicator(
      onRefresh: _refreshSchedules,
      color: theme.colorScheme.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.only(
          left: LayoutConstants.paddingMd,
          right: LayoutConstants.paddingMd,
          bottom: LayoutConstants.spacingXxl * 2,
        ),
        itemCount: _filteredSchedules.length,
        itemBuilder: (context, index) {
          final schedule = _filteredSchedules[index];
          return Padding(
            padding: EdgeInsets.only(bottom: LayoutConstants.spacingMd),
            child: ScheduleCardWidget(
              schedule: schedule,
              onTap: () => _navigateToInspectionDetail(schedule),
              onCallClient: () => _callClient(schedule),
              onGetDirections: () => _getDirections(schedule),
              onReschedule: () => _rescheduleInspection(schedule),
              onMarkComplete: () => _markComplete(schedule),
              onCancel: () => _cancelInspection(schedule),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendarView(ThemeData theme) {
    return CalendarViewWidget(
      schedules: _allSchedules,
      onDateSelected: (date) {
        setState(() {
          _selectedDate = date;
        });
      },
      selectedDate: _selectedDate,
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: context.responsivePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomImageWidget(
              imageUrl:
                  "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
              width: ResponsiveHelper.getResponsiveValue(
                context,
                small: 200,
                medium: 240,
                large: 280,
              ),
              height: ResponsiveHelper.getResponsiveValue(
                context,
                small: 160,
                medium: 180,
                large: 200,
              ),
              fit: BoxFit.contain,
            ),
            SizedBox(height: LayoutConstants.spacingXl),
            Text(
              'No inspections scheduled',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            SizedBox(height: LayoutConstants.spacingLg),
            Text(
              _searchQuery.isNotEmpty || _activeFilters.isNotEmpty
                  ? 'Try adjusting your search or filters'
                  : 'Schedule your first inspection to get started',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: LayoutConstants.spacingXl),
            if (_searchQuery.isEmpty && _activeFilters.isEmpty)
              ElevatedButton.icon(
                onPressed: _addNewInspection,
                icon: CustomIconWidget(
                  iconName: 'add',
                  color: Colors.white,
                  size: LayoutConstants.iconMd,
                ),
                label: Text('Schedule Inspection'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: LayoutConstants.paddingXl,
                    vertical: LayoutConstants.paddingMd,
                  ),
                ),
              )
            else
              TextButton(
                onPressed: _clearSearchAndFilters,
                child: Text('Clear Search & Filters'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(ThemeData theme) {
    return FloatingActionButton.extended(
      onPressed: _addNewInspection,
      icon: CustomIconWidget(
        iconName: 'add',
        color: Colors.white,
        size: 24,
      ),
      label: Text(
        'Add Inspection',
        style: theme.textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: theme.colorScheme.primary,
    );
  }

  // Event handlers
  void _handleSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        currentFilters: _activeFilters,
        onFiltersApplied: (filters) {
          setState(() {
            _activeFilters = filters;
            _applyFilters();
          });
        },
      ),
    );
  }

  void _applyFilters() {
    setState(() {
      _filteredSchedules = _allSchedules.where((schedule) {
        // Search filter
        if (_searchQuery.isNotEmpty) {
          final clientName =
              (schedule['clientName'] as String? ?? '').toLowerCase();
          final propertyAddress =
              (schedule['propertyAddress'] as String? ?? '').toLowerCase();
          final query = _searchQuery.toLowerCase();

          if (!clientName.contains(query) && !propertyAddress.contains(query)) {
            return false;
          }
        }

        // Date range filter
        if (_activeFilters['dateRange'] != null) {
          final dateRange =
              _activeFilters['dateRange'] as Map<String, DateTime>;
          final scheduleDate =
              DateTime.tryParse(schedule['scheduledDate'] as String? ?? '');

          if (scheduleDate == null ||
              scheduleDate.isBefore(dateRange['start']!) ||
              scheduleDate.isAfter(dateRange['end']!)) {
            return false;
          }
        }

        // Property type filter
        if (_activeFilters['propertyType'] != null) {
          final propertyType = schedule['propertyType'] as String? ?? '';
          if (propertyType.toLowerCase() !=
              (_activeFilters['propertyType'] as String).toLowerCase()) {
            return false;
          }
        }

        // Status filter
        if (_activeFilters['statuses'] != null) {
          final statuses = _activeFilters['statuses'] as List<String>;
          final scheduleStatus = schedule['status'] as String? ?? '';
          if (statuses.isNotEmpty && !statuses.contains(scheduleStatus)) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  void _clearSearchAndFilters() {
    setState(() {
      _searchQuery = '';
      _activeFilters.clear();
      _filteredSchedules = List.from(_allSchedules);
    });
  }

  Future<void> _refreshSchedules() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _isLoading = false;
      _filteredSchedules = List.from(_allSchedules);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Schedules updated'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Action handlers
  void _navigateToInspectionDetail(Map<String, dynamic> schedule) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/inspection-detail-screen');
  }

  void _callClient(Map<String, dynamic> schedule) {
    HapticFeedback.lightImpact();
    final phone = schedule['clientPhone'] as String? ?? '';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calling $phone...')),
    );
  }

  void _getDirections(Map<String, dynamic> schedule) {
    HapticFeedback.lightImpact();
    final address = schedule['propertyAddress'] as String? ?? '';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening directions to $address...')),
    );
  }

  void _rescheduleInspection(Map<String, dynamic> schedule) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reschedule feature coming soon')),
    );
  }

  void _markComplete(Map<String, dynamic> schedule) {
    HapticFeedback.mediumImpact();
    setState(() {
      final index = _allSchedules.indexWhere((s) => s['id'] == schedule['id']);
      if (index != -1) {
        _allSchedules[index]['status'] = 'completed';
        _applyFilters();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Inspection marked as complete'),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }

  void _cancelInspection(Map<String, dynamic> schedule) {
    HapticFeedback.mediumImpact();
    setState(() {
      final index = _allSchedules.indexWhere((s) => s['id'] == schedule['id']);
      if (index != -1) {
        _allSchedules[index]['status'] = 'cancelled';
        _applyFilters();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Inspection cancelled'),
        backgroundColor: AppTheme.errorLight,
      ),
    );
  }

  void _addNewInspection() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Schedule creation feature coming soon')),
    );
  }
}

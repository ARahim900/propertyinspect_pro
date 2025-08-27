import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/layout_constants.dart';
import '../../utils/responsive_helper.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/activity_item_widget.dart';
import './widgets/greeting_header_widget.dart';
import './widgets/metric_card_widget.dart';
import './widgets/quick_actions_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = false;
  DateTime _lastUpdated = DateTime.now();

  // Mock data for dashboard metrics
  final List<Map<String, dynamic>> _metrics = [
    {
      'title': 'Today\'s Inspections',
      'value': '8',
      'subtitle': '3 completed, 5 pending',
      'icon': Icons.schedule,
      'showTrend': true,
      'trendValue': '+12%',
      'isPositiveTrend': true,
    },
    {
      'title': 'Completed This Week',
      'value': '24',
      'subtitle': 'Target: 30 inspections',
      'icon': Icons.check_circle,
      'showTrend': true,
      'trendValue': '+8%',
      'isPositiveTrend': true,
    },
    {
      'title': 'Pending Invoices',
      'value': '12',
      'subtitle': 'Total: \$8,450',
      'icon': Icons.receipt,
      'showTrend': true,
      'trendValue': '-5%',
      'isPositiveTrend': false,
    },
    {
      'title': 'Avg. Completion Time',
      'value': '2.5h',
      'subtitle': 'Per inspection',
      'icon': Icons.timer,
      'showTrend': true,
      'trendValue': '-15min',
      'isPositiveTrend': true,
    },
  ];

  // Mock data for recent activities
  final List<Map<String, dynamic>> _recentActivities = [
    {
      'type': 'completion',
      'title': 'Inspection Completed',
      'description':
          'Residential property at 123 Oak Street - All items passed',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
      'status': 'Completed',
    },
    {
      'type': 'schedule',
      'title': 'New Inspection Scheduled',
      'description': 'Commercial building at 456 Main Ave - Tomorrow 10:00 AM',
      'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
      'status': 'Scheduled',
    },
    {
      'type': 'invoice',
      'title': 'Invoice Generated',
      'description': 'Invoice #INV-2024-0156 for \$650 - Sent to client',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'status': 'Sent',
    },
    {
      'type': 'inspection',
      'title': 'Inspection Started',
      'description': 'Multi-family unit at 789 Pine Road - In progress',
      'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
      'status': 'In Progress',
    },
    {
      'type': 'invoice',
      'title': 'Payment Received',
      'description': 'Invoice #INV-2024-0155 for \$850 - Payment confirmed',
      'timestamp': DateTime.now().subtract(const Duration(hours: 4)),
      'status': 'Paid',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        title: 'PropertyInspect Pro',
        variant: CustomAppBarVariant.standard,
        showBackButton: false,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting Header
                GreetingHeaderWidget(
                  userName: 'John Inspector',
                  currentDate: DateTime.now(),
                ),

                SizedBox(height: LayoutConstants.spacingLg),

                // Metrics Cards
                _buildMetricsSection(),

                SizedBox(height: LayoutConstants.spacingXl),

                // Quick Actions
                Padding(
                  padding: context.responsiveHorizontalPadding,
                  child: QuickActionsWidget(
                    onStartInspection: () => _navigateToInspection(),
                    onViewSchedule: () => _navigateToSchedule(),
                    onCreateInvoice: () => _navigateToInvoice(),
                    onViewReports: () => _showReportsDialog(),
                  ),
                ),

                SizedBox(height: LayoutConstants.spacingXl),

                // Recent Activity Section
                _buildRecentActivitySection(),

                SizedBox(height: LayoutConstants.spacingXxl * 2), // Bottom padding for FAB
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startQuickInspection,
        icon: CustomIconWidget(
          iconName: 'play_circle_filled',
          color: Colors.white,
          size: 6.w,
        ),
        label: Text(
          'Start Inspection',
          style: theme.textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
      ),
      bottomNavigationBar: const CustomBottomBar(
        currentIndex: 0,
        variant: CustomBottomBarVariant.standard,
      ),
    );
  }

  Widget _buildMetricsSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: context.responsiveHorizontalPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Overview',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                'Last updated: ${_formatLastUpdated()}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: LayoutConstants.spacingLg),
        // Improved responsive grid layout
        Padding(
          padding: context.responsiveHorizontalPadding,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Get optimal number of columns based on screen size
              final columns = ResponsiveHelper.getOptimalColumns(context, minCardWidth: 160);
              final cardWidth = ResponsiveHelper.getCardWidth(context, columns: columns);
              final cardHeight = ResponsiveHelper.getOptimalCardHeight(
                context,
                contentHeight: cardWidth * LayoutConstants.cardAspectRatioMetric,
                minHeight: LayoutConstants.cardMinHeight,
              );
              
              return Wrap(
                spacing: LayoutConstants.gridSpacing,
                runSpacing: LayoutConstants.gridSpacing,
                children: _metrics.asMap().entries.map((entry) {
                  final index = entry.key;
                  final metric = entry.value;
                  
                  return SizedBox(
                    width: cardWidth,
                    height: cardHeight,
                    child: MetricCardWidget(
                      title: metric['title'],
                      value: metric['value'],
                      subtitle: metric['subtitle'],
                      icon: metric['icon'],
                      showTrend: metric['showTrend'] ?? false,
                      trendValue: metric['trendValue'],
                      isPositiveTrend: metric['isPositiveTrend'] ?? true,
                      onTap: () => _onMetricTap(index),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: context.responsiveHorizontalPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Row(
                children: [
                  if (kDebugMode)
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/debug-screen'),
                      child: Text(
                        'Debug',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  TextButton(
                    onPressed: () => _viewAllActivities(),
                    child: Text(
                      'View All',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: LayoutConstants.spacingLg),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: context.responsiveHorizontalPadding,
          itemCount: _recentActivities.length,
          itemBuilder: (context, index) {
            final activity = _recentActivities[index];
            return Padding(
              padding: EdgeInsets.only(bottom: LayoutConstants.spacingSm),
              child: ActivityItemWidget(
                activity: activity,
                onTap: () => _onActivityTap(activity),
                onLongPress: () => _showActivityContextMenu(context, activity),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
      _lastUpdated = DateTime.now();
    });

    HapticFeedback.lightImpact();
  }

  String _formatLastUpdated() {
    final now = DateTime.now();
    final difference = now.difference(_lastUpdated);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${_lastUpdated.hour}:${_lastUpdated.minute.toString().padLeft(2, '0')}';
    }
  }

  void _onMetricTap(int index) {
    HapticFeedback.lightImpact();
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/schedule-list-screen');
        break;
      case 1:
        Navigator.pushNamed(context, '/inspection-detail-screen');
        break;
      case 2:
        Navigator.pushNamed(context, '/invoice-generation-screen');
        break;
      case 3:
        _showCompletionTimeDetails();
        break;
    }
  }

  void _onActivityTap(Map<String, dynamic> activity) {
    HapticFeedback.lightImpact();
    final type = activity['type'] as String;

    switch (type) {
      case 'inspection':
      case 'completion':
        Navigator.pushNamed(context, '/inspection-detail-screen');
        break;
      case 'schedule':
        Navigator.pushNamed(context, '/schedule-list-screen');
        break;
      case 'invoice':
        Navigator.pushNamed(context, '/invoice-generation-screen');
        break;
    }
  }

  void _showActivityContextMenu(
      BuildContext context, Map<String, dynamic> activity) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4.w)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'visibility',
                color: Theme.of(context).colorScheme.primary,
                size: 6.w,
              ),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                _onActivityTap(activity);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: Theme.of(context).colorScheme.secondary,
                size: 6.w,
              ),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                _shareActivity(activity);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'flag',
                color: AppTheme.warningLight,
                size: 6.w,
              ),
              title: const Text('Mark Priority'),
              onTap: () {
                Navigator.pop(context);
                _markActivityPriority(activity);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToInspection() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/inspection-detail-screen');
  }

  void _navigateToSchedule() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/schedule-list-screen');
  }

  void _navigateToInvoice() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/invoice-generation-screen');
  }

  void _startQuickInspection() {
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(context, '/inspection-detail-screen');
  }

  void _viewAllActivities() {
    HapticFeedback.lightImpact();
    // Navigate to activities screen or show expanded view
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Viewing all activities...'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.w),
        ),
      ),
    );
  }

  void _showReportsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reports'),
        content: const Text(
            'Reports feature coming soon! You\'ll be able to view detailed analytics and export inspection reports.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCompletionTimeDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Completion Time Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Average completion time breakdown:'),
            SizedBox(height: 1.h),
            const Text('• Residential: 2.2 hours'),
            const Text('• Commercial: 3.1 hours'),
            const Text('• Multi-family: 2.8 hours'),
            SizedBox(height: 1.h),
            const Text(
                'This week\'s improvement: 15 minutes faster per inspection'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _shareActivity(Map<String, dynamic> activity) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing: ${activity['title']}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.w),
        ),
      ),
    );
  }

  void _markActivityPriority(Map<String, dynamic> activity) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Marked as priority: ${activity['title']}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.w),
        ),
      ),
    );
  }
}

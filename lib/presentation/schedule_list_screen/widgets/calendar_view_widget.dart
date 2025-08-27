import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CalendarViewWidget extends StatefulWidget {
  final List<Map<String, dynamic>> schedules;
  final Function(DateTime) onDateSelected;
  final DateTime selectedDate;

  const CalendarViewWidget({
    super.key,
    required this.schedules,
    required this.onDateSelected,
    required this.selectedDate,
  });

  @override
  State<CalendarViewWidget> createState() => _CalendarViewWidgetState();
}

class _CalendarViewWidgetState extends State<CalendarViewWidget> {
  late DateTime _currentMonth;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentMonth =
        DateTime(widget.selectedDate.year, widget.selectedDate.month);
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        _buildCalendarHeader(theme),
        _buildWeekdayHeaders(theme),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentMonth = DateTime(
                    _currentMonth.year, _currentMonth.month + (index - 1000));
              });
            },
            itemBuilder: (context, index) {
              final month = DateTime(
                  _currentMonth.year, _currentMonth.month + (index - 1000));
              return _buildCalendarGrid(theme, month);
            },
          ),
        ),
        _buildSelectedDateInspections(theme),
      ],
    );
  }

  Widget _buildCalendarHeader(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                _currentMonth =
                    DateTime(_currentMonth.year, _currentMonth.month - 1);
              });
              _pageController.previousPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            icon: CustomIconWidget(
              iconName: 'chevron_left',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
          ),
          Text(
            _getMonthYearString(_currentMonth),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                _currentMonth =
                    DateTime(_currentMonth.year, _currentMonth.month + 1);
              });
              _pageController.nextPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            icon: CustomIconWidget(
              iconName: 'chevron_right',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders(ThemeData theme) {
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: weekdays
            .map((day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(ThemeData theme, DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    final days = <Widget>[];

    // Add empty cells for days before the first day of the month
    for (int i = 0; i < firstDayWeekday; i++) {
      days.add(Container());
    }

    // Add days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      final inspectionsOnDate = _getInspectionsForDate(date);
      final isSelected = _isSameDay(date, widget.selectedDate);
      final isToday = _isSameDay(date, DateTime.now());

      days.add(
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onDateSelected(date);
          },
          child: Container(
            margin: EdgeInsets.all(1.w),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : isToday
                      ? theme.colorScheme.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isToday && !isSelected
                  ? Border.all(color: theme.colorScheme.primary, width: 1)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day.toString(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? Colors.white
                        : isToday
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                    fontWeight: isSelected || isToday
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
                if (inspectionsOnDate.isNotEmpty) ...[
                  SizedBox(height: 0.5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0;
                          i < inspectionsOnDate.length && i < 3;
                          i++)
                        Container(
                          width: 1.5.w,
                          height: 1.5.w,
                          margin: EdgeInsets.symmetric(horizontal: 0.5.w),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : _getStatusColor(
                                    inspectionsOnDate[i]['status'] as String? ??
                                        'scheduled'),
                            shape: BoxShape.circle,
                          ),
                        ),
                      if (inspectionsOnDate.length > 3)
                        Text(
                          '+${inspectionsOnDate.length - 3}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isSelected
                                ? Colors.white
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                            fontSize: 8.sp,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: GridView.count(
        crossAxisCount: 7,
        children: days,
      ),
    );
  }

  Widget _buildSelectedDateInspections(ThemeData theme) {
    final inspections = _getInspectionsForDate(widget.selectedDate);

    if (inspections.isEmpty) {
      return Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: 'event_available',
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text(
              'No inspections scheduled',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'for ${_getDateString(widget.selectedDate)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      constraints: BoxConstraints(maxHeight: 30.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Text(
              'Inspections for ${_getDateString(widget.selectedDate)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: inspections.length,
              itemBuilder: (context, index) {
                final inspection = inspections[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 1.h),
                  child: ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                                inspection['status'] as String? ?? 'scheduled')
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: 'assignment',
                        color: _getStatusColor(
                            inspection['status'] as String? ?? 'scheduled'),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      inspection['clientName'] as String? ?? 'Unknown Client',
                      style: theme.textTheme.titleSmall,
                    ),
                    subtitle: Text(
                      '${inspection['scheduledTime'] ?? 'Time not set'} • ${inspection['propertyAddress'] ?? 'No address'}',
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                                inspection['status'] as String? ?? 'scheduled')
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        (inspection['status'] as String? ?? 'scheduled')
                            .toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: _getStatusColor(
                              inspection['status'] as String? ?? 'scheduled'),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pushNamed(context, '/inspection-detail-screen');
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getInspectionsForDate(DateTime date) {
    return widget.schedules.where((schedule) {
      final scheduledDate =
          DateTime.tryParse(schedule['scheduledDate'] as String? ?? '');
      return scheduledDate != null && _isSameDay(scheduledDate, date);
    }).toList();
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getMonthYearString(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _getDateString(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppTheme.successLight;
      case 'in_progress':
        return AppTheme.warningLight;
      case 'cancelled':
        return AppTheme.errorLight;
      case 'scheduled':
      default:
        return AppTheme.primaryLight;
    }
  }
}

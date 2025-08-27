import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './photo_gallery_widget.dart';

class InspectionItemWidget extends StatefulWidget {
  final Map<String, dynamic> itemData;
  final String areaId;
  final Function(String) onStatusChanged;
  final Function(String) onCommentChanged;
  final VoidCallback onPhotoAdded;

  const InspectionItemWidget({
    super.key,
    required this.itemData,
    required this.areaId,
    required this.onStatusChanged,
    required this.onCommentChanged,
    required this.onPhotoAdded,
  });

  @override
  State<InspectionItemWidget> createState() => _InspectionItemWidgetState();
}

class _InspectionItemWidgetState extends State<InspectionItemWidget> {
  bool _showCommentField = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _commentController.text = widget.itemData['comment'] as String? ?? '';
    _showCommentField = _commentController.text.isNotEmpty;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = widget.itemData['status'] as String? ?? 'pending';
    final photos = (widget.itemData['photos'] as List?) ?? [];

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8.w),
        border: Border.all(
          color: _getStatusBorderColor(status, theme),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.itemData['name'] as String? ?? 'Inspection Item',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              _buildStatusIcon(status, theme),
            ],
          ),
          if (widget.itemData['description'] != null) ...[
            SizedBox(height: 8.h),
            Text(
              widget.itemData['description'] as String,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
          SizedBox(height: 16.h),

          // Status Selection
          Row(
            children: [
              Expanded(
                child: _buildStatusButton('pass', 'Pass', theme),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildStatusButton('fail', 'Fail', theme),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildStatusButton('na', 'N/A', theme),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _showCommentField = !_showCommentField;
                    });
                  },
                  icon: CustomIconWidget(
                    iconName: 'comment',
                    color: theme.colorScheme.primary,
                    size: 16.w,
                  ),
                  label: Text(
                    _showCommentField ? 'Hide Comment' : 'Add Comment',
                    style: theme.textTheme.labelMedium,
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    widget.onPhotoAdded();
                  },
                  icon: CustomIconWidget(
                    iconName: 'camera_alt',
                    color: theme.colorScheme.primary,
                    size: 16.w,
                  ),
                  label: Text(
                    'Add Photo',
                    style: theme.textTheme.labelMedium,
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                  ),
                ),
              ),
            ],
          ),

          // Comment Field
          if (_showCommentField) ...[
            SizedBox(height: 12.h),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Add your comment here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.w),
                ),
                contentPadding: EdgeInsets.all(12.w),
              ),
              maxLines: 3,
              onChanged: (value) {
                widget.onCommentChanged(value);
              },
            ),
          ],

          // Photo Gallery
          if (photos.isNotEmpty) ...[
            SizedBox(height: 12.h),
            PhotoGalleryWidget(
              photos: photos.cast<String>(),
              onPhotoTap: (index) =>
                  _showPhotoViewer(context, photos.cast<String>(), index),
              onPhotoDelete: (index) => _deletePhoto(index),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusButton(String statusValue, String label, ThemeData theme) {
    final isSelected =
        (widget.itemData['status'] as String? ?? 'pending') == statusValue;
    final color = _getStatusColor(statusValue, theme);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onStatusChanged(statusValue);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(6.w),
          border: Border.all(
            color: isSelected
                ? color
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: isSelected
                  ? 'radio_button_checked'
                  : 'radio_button_unchecked',
              color: isSelected ? color : theme.colorScheme.outline,
              size: 16.w,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? color
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(String status, ThemeData theme) {
    final color = _getStatusColor(status, theme);
    String iconName;

    switch (status) {
      case 'pass':
        iconName = 'check_circle';
        break;
      case 'fail':
        iconName = 'cancel';
        break;
      case 'na':
        iconName = 'remove_circle';
        break;
      default:
        iconName = 'radio_button_unchecked';
    }

    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: CustomIconWidget(
        iconName: iconName,
        color: color,
        size: 16.w,
      ),
    );
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status) {
      case 'pass':
        return AppTheme.successLight;
      case 'fail':
        return AppTheme.errorLight;
      case 'na':
        return AppTheme.warningLight;
      default:
        return theme.colorScheme.outline;
    }
  }

  Color _getStatusBorderColor(String status, ThemeData theme) {
    switch (status) {
      case 'pass':
        return AppTheme.successLight.withValues(alpha: 0.3);
      case 'fail':
        return AppTheme.errorLight.withValues(alpha: 0.3);
      case 'na':
        return AppTheme.warningLight.withValues(alpha: 0.3);
      default:
        return theme.colorScheme.outline.withValues(alpha: 0.2);
    }
  }

  void _showPhotoViewer(
      BuildContext context, List<String> photos, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              '${initialIndex + 1} of ${photos.length}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          body: PageView.builder(
            controller: PageController(initialPage: initialIndex),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              return Center(
                child: InteractiveViewer(
                  child: CustomImageWidget(
                    imageUrl: photos[index],
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _deletePhoto(int index) {
    // Implementation for photo deletion
    HapticFeedback.lightImpact();
    // This would typically update the photos list in the parent state
  }
}

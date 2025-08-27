import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/camera_overlay_widget.dart';
import './widgets/inspection_area_widget.dart';
import './widgets/progress_indicator_widget.dart';
import './widgets/property_header_widget.dart';

class InspectionDetailScreen extends StatefulWidget {
  const InspectionDetailScreen({super.key});

  @override
  State<InspectionDetailScreen> createState() => _InspectionDetailScreenState();
}

class _InspectionDetailScreenState extends State<InspectionDetailScreen> {
  bool _isLoading = false;
  bool _isSaving = false;

  // Mock inspection data
  final Map<String, dynamic> _inspectionData = {
    "id": "INS-2025-001",
    "property": {
      "address": "1234 Oak Street",
      "city": "San Francisco",
      "state": "CA",
      "zipCode": "94102",
      "clientName": "Sarah Johnson",
      "clientPhone": "+1 (555) 123-4567",
      "scheduledDate": "Aug 26, 2025",
      "scheduledTime": "10:00 AM",
      "status": "in_progress"
    },
    "areas": [
      {
        "id": "area_1",
        "name": "Kitchen",
        "icon": "kitchen",
        "items": [
          {
            "id": "item_1",
            "name": "Electrical Outlets",
            "description": "Check all outlets for proper function and safety",
            "status": "pass",
            "comment": "All outlets working properly",
            "photos": [
              "https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400",
              "https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400"
            ]
          },
          {
            "id": "item_2",
            "name": "Plumbing Fixtures",
            "description": "Inspect faucets, disposal, and under-sink plumbing",
            "status": "fail",
            "comment": "Minor leak detected under sink",
            "photos": []
          },
          {
            "id": "item_3",
            "name": "Appliances",
            "description": "Test all built-in appliances",
            "status": "pending",
            "comment": "",
            "photos": []
          }
        ]
      },
      {
        "id": "area_2",
        "name": "Living Room",
        "icon": "living",
        "items": [
          {
            "id": "item_4",
            "name": "Windows",
            "description": "Check window operation and seals",
            "status": "pass",
            "comment": "",
            "photos": []
          },
          {
            "id": "item_5",
            "name": "Flooring",
            "description": "Inspect flooring condition",
            "status": "na",
            "comment": "Carpet to be replaced by owner",
            "photos": []
          }
        ]
      },
      {
        "id": "area_3",
        "name": "Bathroom",
        "icon": "bathroom",
        "items": [
          {
            "id": "item_6",
            "name": "Shower/Tub",
            "description": "Test water pressure and drainage",
            "status": "pending",
            "comment": "",
            "photos": []
          },
          {
            "id": "item_7",
            "name": "Ventilation",
            "description": "Check exhaust fan operation",
            "status": "pending",
            "comment": "",
            "photos": []
          }
        ]
      }
    ]
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final areas = (_inspectionData['areas'] as List?) ?? [];
    final progress = _calculateProgress();
    final completedItems = _getCompletedItemsCount();
    final totalItems = _getTotalItemsCount();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Inspection Details',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back_ios',
            color: theme.colorScheme.onSurface,
            size: 20.w,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'more_vert',
              color: theme.colorScheme.onSurface,
              size: 24.w,
            ),
            onPressed: () => _showOptionsMenu(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        SizedBox(height: 8.h),
                        PropertyHeaderWidget(
                          propertyData: _inspectionData['property']
                              as Map<String, dynamic>,
                        ),
                        SizedBox(height: 16.h),
                        ProgressIndicatorWidget(
                          progress: progress,
                          completedItems: completedItems,
                          totalItems: totalItems,
                        ),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final area = areas[index] as Map<String, dynamic>;
                        return InspectionAreaWidget(
                          areaData: area,
                          onItemStatusChanged: _onItemStatusChanged,
                          onCommentChanged: _onCommentChanged,
                          onPhotoAdded: _onPhotoAdded,
                        );
                      },
                      childCount: areas.length,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(height: 100.h), // Space for FAB
                  ),
                ],
              ),
            ),
      floatingActionButton: _buildFloatingActionButton(context, progress),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, double progress) {
    final theme = Theme.of(context);
    final isComplete = progress == 1.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: SizedBox(
        width: double.infinity,
        height: 56.h,
        child: FloatingActionButton.extended(
          onPressed: _isSaving
              ? null
              : () => isComplete ? _completeInspection() : _saveDraft(),
          backgroundColor:
              isComplete ? AppTheme.successLight : theme.colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          icon: _isSaving
              ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : CustomIconWidget(
                  iconName: isComplete ? 'check_circle' : 'save',
                  color: Colors.white,
                  size: 20.w,
                ),
          label: Text(
            _isSaving
                ? 'Saving...'
                : isComplete
                    ? 'Complete Inspection'
                    : 'Save Draft',
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  double _calculateProgress() {
    final areas = (_inspectionData['areas'] as List?) ?? [];
    int totalItems = 0;
    int completedItems = 0;

    for (final area in areas) {
      final items = ((area as Map<String, dynamic>)['items'] as List?) ?? [];
      totalItems += items.length;

      for (final item in items) {
        final status =
            ((item as Map<String, dynamic>)['status'] as String?) ?? 'pending';
        if (status != 'pending') {
          completedItems++;
        }
      }
    }

    return totalItems > 0 ? completedItems / totalItems : 0.0;
  }

  int _getCompletedItemsCount() {
    final areas = (_inspectionData['areas'] as List?) ?? [];
    int completedItems = 0;

    for (final area in areas) {
      final items = ((area as Map<String, dynamic>)['items'] as List?) ?? [];
      for (final item in items) {
        final status =
            ((item as Map<String, dynamic>)['status'] as String?) ?? 'pending';
        if (status != 'pending') {
          completedItems++;
        }
      }
    }

    return completedItems;
  }

  int _getTotalItemsCount() {
    final areas = (_inspectionData['areas'] as List?) ?? [];
    int totalItems = 0;

    for (final area in areas) {
      final items = ((area as Map<String, dynamic>)['items'] as List?) ?? [];
      totalItems += items.length;
    }

    return totalItems;
  }

  void _onItemStatusChanged(String areaId, String itemId, String status) {
    setState(() {
      final areas = (_inspectionData['areas'] as List?) ?? [];
      for (final area in areas) {
        if ((area as Map<String, dynamic>)['id'] == areaId) {
          final items = (area['items'] as List?) ?? [];
          for (final item in items) {
            if ((item as Map<String, dynamic>)['id'] == itemId) {
              item['status'] = status;
              break;
            }
          }
          break;
        }
      }
    });

    HapticFeedback.lightImpact();
    _autoSave();
  }

  void _onCommentChanged(String areaId, String itemId, String comment) {
    setState(() {
      final areas = (_inspectionData['areas'] as List?) ?? [];
      for (final area in areas) {
        if ((area as Map<String, dynamic>)['id'] == areaId) {
          final items = (area['items'] as List?) ?? [];
          for (final item in items) {
            if ((item as Map<String, dynamic>)['id'] == itemId) {
              item['comment'] = comment;
              break;
            }
          }
          break;
        }
      }
    });

    _autoSave();
  }

  void _onPhotoAdded(String areaId, String itemId) {
    // Find the area and item
    String areaName = '';
    String itemName = '';

    final areas = (_inspectionData['areas'] as List?) ?? [];
    for (final area in areas) {
      if ((area as Map<String, dynamic>)['id'] == areaId) {
        areaName = area['name'] as String? ?? '';
        final items = (area['items'] as List?) ?? [];
        for (final item in items) {
          if ((item as Map<String, dynamic>)['id'] == itemId) {
            itemName = item['name'] as String? ?? '';
            break;
          }
        }
        break;
      }
    }

    // Show camera overlay
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CameraOverlayWidget(
          itemName: itemName,
          areaName: areaName,
          onPhotoTaken: (photoPath) {
            _addPhotoToItem(areaId, itemId, photoPath);
          },
        ),
      ),
    );
  }

  void _addPhotoToItem(String areaId, String itemId, String photoPath) {
    setState(() {
      final areas = (_inspectionData['areas'] as List?) ?? [];
      for (final area in areas) {
        if ((area as Map<String, dynamic>)['id'] == areaId) {
          final items = (area['items'] as List?) ?? [];
          for (final item in items) {
            if ((item as Map<String, dynamic>)['id'] == itemId) {
              final photos = (item['photos'] as List?) ?? [];
              photos.add(photoPath);
              item['photos'] = photos;
              break;
            }
          }
          break;
        }
      }
    });

    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo added successfully'),
        duration: Duration(seconds: 2),
      ),
    );

    _autoSave();
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveDraft() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Simulate save operation
      await Future.delayed(const Duration(seconds: 1));

      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Draft saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save draft'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _completeInspection() async {
    final shouldComplete = await _showCompletionDialog();
    if (!shouldComplete) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Simulate completion operation
      await Future.delayed(const Duration(seconds: 2));

      HapticFeedback.mediumImpact();

      // Show success dialog and navigate
      _showCompletionSuccess();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to complete inspection'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<bool> _showCompletionDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Complete Inspection'),
              content: const Text(
                'Are you sure you want to complete this inspection? This action cannot be undone.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successLight,
                  ),
                  child: const Text('Complete'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _showCompletionSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: AppTheme.successLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30.w),
                ),
                child: CustomIconWidget(
                  iconName: 'check_circle',
                  color: AppTheme.successLight,
                  size: 32.w,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Inspection Completed!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'Your inspection has been successfully completed and saved.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Return to previous screen
              },
              child: const Text('Back to List'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/invoice-generation-screen');
              },
              child: const Text('Generate Invoice'),
            ),
          ],
        );
      },
    );
  }

  void _autoSave() {
    // Implement auto-save functionality
    // This would typically save to local storage for offline capability
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: const Text('Share Inspection'),
              onTap: () {
                Navigator.pop(context);
                // Implement share functionality
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'download',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: const Text('Export Report'),
              onTap: () {
                Navigator.pop(context);
                // Implement export functionality
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'schedule',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: const Text('Reschedule'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to reschedule screen
              },
            ),
          ],
        ),
      ),
    );
  }
}

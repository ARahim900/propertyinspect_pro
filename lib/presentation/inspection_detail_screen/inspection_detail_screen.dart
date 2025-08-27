import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../services/inspection_service.dart';
import '../../services/supabase_service.dart';
import '../../utils/responsive_helper.dart';
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
  final InspectionService _inspectionService = InspectionService();

  // Real inspection data from Supabase
  Map<String, dynamic>? _inspectionData;

  @override
  void initState() {
    super.initState();
    _loadInspectionData();
  }

  Future<void> _loadInspectionData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final args = ModalRoute.of(context)?.settings.arguments as String?;

      if (args != null && SupabaseService.instance.isAuthenticated) {
        // Load real inspection data from Supabase
        final data = await _inspectionService.getInspectionDetails(args);

        // Transform the data to match expected format
        final transformedData = {
          "id": data['id'],
          "property": {
            "address": data['property_location'] ?? 'Unknown Location',
            "city": _extractCity(data['property_location']),
            "clientName": data['client_name'] ?? 'Unknown Client',
            "scheduledDate": _formatDate(data['inspection_date']),
            "scheduledTime": "10:00 AM", // Default time
            "status": "in_progress"
          },
          "areas": _transformAreas(data['inspection_areas'] ?? [])
        };

        setState(() {
          _inspectionData = transformedData;
        });
      } else {
        // Fallback data for preview mode - using realistic Omani locations
        _inspectionData = {
          "id": "INS-2025-001",
          "property": {
            "address": "Al Qurum Heights, Muscat",
            "city": "Muscat",
            "clientName": "Ahmed Al Balushi",
            "scheduledDate": "Aug 26, 2025",
            "scheduledTime": "10:00 AM",
            "status": "in_progress"
          },
          "areas": [
            {
              "id": "area_1",
              "name": "Majlis (Living Room)",
              "icon": "living",
              "items": [
                {
                  "id": "item_1",
                  "name": "Electrical Outlets",
                  "description":
                      "Check all outlets for proper function and safety",
                  "status": "pass",
                  "comment": "All outlets working properly",
                  "photos": []
                },
                {
                  "id": "item_2",
                  "name": "Air Conditioning",
                  "description": "Inspect AC units and ductwork",
                  "status": "pending",
                  "comment": "",
                  "photos": []
                }
              ]
            },
            {
              "id": "area_2",
              "name": "Kitchen",
              "icon": "kitchen",
              "items": [
                {
                  "id": "item_3",
                  "name": "Plumbing Fixtures",
                  "description": "Inspect faucets and under-sink plumbing",
                  "status": "pending",
                  "comment": "",
                  "photos": []
                }
              ]
            }
          ]
        };
      }
    } catch (error) {
      // Fallback data on error
      _inspectionData = {
        "id": "INS-2025-001",
        "property": {
          "address": "Al Qurum Heights, Muscat",
          "city": "Muscat",
          "clientName": "Ahmed Al Balushi",
          "scheduledDate": "Aug 26, 2025",
          "scheduledTime": "10:00 AM",
          "status": "in_progress"
        },
        "areas": []
      };
    }

    setState(() {
      _isLoading = false;
    });
  }

  String _extractCity(String? location) {
    if (location == null) return 'Unknown';
    // Simple city extraction - you can enhance this logic
    if (location.toLowerCase().contains('muscat')) return 'Muscat';
    if (location.toLowerCase().contains('salalah')) return 'Salalah';
    if (location.toLowerCase().contains('nizwa')) return 'Nizwa';
    return location.split(',').last.trim();
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown Date';
    try {
      final date = DateTime.parse(dateString);
      return "${_getMonthName(date.month)} ${date.day}, ${date.year}";
    } catch (e) {
      return dateString;
    }
  }

  String _getMonthName(int month) {
    const months = [
      '',
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
    return months[month];
  }

  List<Map<String, dynamic>> _transformAreas(List<dynamic> areas) {
    return areas.map<Map<String, dynamic>>((area) {
      return {
        "id": area['id'],
        "name": area['name'],
        "icon": _getAreaIcon(area['name']),
        "items": _transformItems(area['inspection_items'] ?? [])
      };
    }).toList();
  }

  String _getAreaIcon(String areaName) {
    final name = areaName.toLowerCase();
    if (name.contains('kitchen')) return 'kitchen';
    if (name.contains('bathroom')) return 'bathroom';
    if (name.contains('majlis') || name.contains('living')) return 'living';
    if (name.contains('bedroom')) return 'bed';
    return 'room';
  }

  List<Map<String, dynamic>> _transformItems(List<dynamic> items) {
    return items.map<Map<String, dynamic>>((item) {
      return {
        "id": item['id'],
        "name": item['point'],
        "description": "${item['category']} - ${item['point']}",
        "status": _normalizeStatus(item['status']),
        "comment": item['comments'] ?? '',
        "photos": item['photos'] ?? []
      };
    }).toList();
  }

  String _normalizeStatus(String? status) {
    if (status == null) return 'pending';
    switch (status.toLowerCase()) {
      case 'pass':
        return 'pass';
      case 'fail':
        return 'fail';
      case 'n/a':
        return 'na';
      default:
        return 'pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final areas = (_inspectionData?['areas'] as List?) ?? [];
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
            size: ResponsiveHelper.getIconSize(context, small: 20),
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
              size: ResponsiveHelper.getIconSize(context, small: 24),
            ),
            onPressed: () => _showOptionsMenu(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            SizedBox(
                                height: ResponsiveHelper.getSpacing(context,
                                    small: 8)),
                            if (_inspectionData != null)
                              PropertyHeaderWidget(
                                propertyData: _inspectionData!['property']
                                        as Map<String, dynamic>? ??
                                    {},
                              ),
                            SizedBox(
                                height: ResponsiveHelper.getSpacing(context,
                                    small: 8)),
                            ProgressIndicatorWidget(
                              progress: progress,
                              completedItems: completedItems,
                              totalItems: totalItems,
                            ),
                            SizedBox(
                                height: ResponsiveHelper.getSpacing(context,
                                    small: 16)),
                          ],
                        ),
                      ),
                      // Responsive content based on screen size
                      constraints.maxWidth > 800
                          ? _buildTabletLayout(areas)
                          : _buildMobileLayout(areas),
                      SliverToBoxAdapter(
                        child: SizedBox(
                            height: ResponsiveHelper.getSpacing(context,
                                small: 100)),
                      ),
                    ],
                  );
                },
              ),
            ),
      floatingActionButton: _buildFloatingActionButton(context, progress),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // Mobile layout - single column
  Widget _buildMobileLayout(List areas) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final area = areas[index] as Map<String, dynamic>;
          return Padding(
            padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.getSpacing(context, small: 16)),
            child: InspectionAreaWidget(
              areaData: area,
              onItemStatusChanged: _onItemStatusChanged,
              onCommentChanged: _onCommentChanged,
              onPhotoAdded: _onPhotoAdded,
            ),
          );
        },
        childCount: areas.length,
      ),
    );
  }

  // Tablet layout - two columns
  Widget _buildTabletLayout(List areas) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getSpacing(context, small: 16)),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: ResponsiveHelper.getSpacing(context, small: 16),
          mainAxisSpacing: ResponsiveHelper.getSpacing(context, small: 8),
          childAspectRatio: 0.8, // Adjust based on content
        ),
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
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, double progress) {
    final theme = Theme.of(context);
    final isComplete = progress == 1.0;

    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getSpacing(context, small: 16)),
      child: SizedBox(
        width: double.infinity,
        height: ResponsiveHelper.getButtonHeight(context),
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
                  width: ResponsiveHelper.getIconSize(context, small: 20),
                  height: ResponsiveHelper.getIconSize(context, small: 20),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : CustomIconWidget(
                  iconName: isComplete ? 'check_circle' : 'save',
                  color: Colors.white,
                  size: ResponsiveHelper.getIconSize(context, small: 20),
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
    final areas = (_inspectionData?['areas'] as List?) ?? [];
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
    final areas = (_inspectionData?['areas'] as List?) ?? [];
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
    final areas = (_inspectionData?['areas'] as List?) ?? [];
    int totalItems = 0;

    for (final area in areas) {
      final items = ((area as Map<String, dynamic>)['items'] as List?) ?? [];
      totalItems += items.length;
    }

    return totalItems;
  }

  void _onItemStatusChanged(String areaId, String itemId, String status) async {
    setState(() {
      final areas = (_inspectionData?['areas'] as List?) ?? [];
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

    // Update in database if authenticated
    if (SupabaseService.instance.isAuthenticated) {
      try {
        await _inspectionService.updateInspectionItem(itemId, status: status);
      } catch (e) {
        // Handle error silently or show snackbar
      }
    }

    HapticFeedback.lightImpact();
  }

  void _onCommentChanged(String areaId, String itemId, String comment) async {
    setState(() {
      final areas = (_inspectionData?['areas'] as List?) ?? [];
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

    // Update in database if authenticated
    if (SupabaseService.instance.isAuthenticated) {
      try {
        await _inspectionService.updateInspectionItem(itemId,
            comments: comment);
      } catch (e) {
        // Handle error silently
      }
    }
  }

  void _onPhotoAdded(String areaId, String itemId) {
    // Find the area and item
    String areaName = '';
    String itemName = '';

    final areas = (_inspectionData?['areas'] as List?) ?? [];
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

  void _addPhotoToItem(String areaId, String itemId, String photoPath) async {
    setState(() {
      final areas = (_inspectionData?['areas'] as List?) ?? [];
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

    // Upload to database if authenticated
    if (SupabaseService.instance.isAuthenticated) {
      try {
        final photoUrl =
            await _inspectionService.uploadInspectionPhoto(photoPath, itemId);

        // Update the photos array with the uploaded URL
        setState(() {
          final areas = (_inspectionData?['areas'] as List?) ?? [];
          for (final area in areas) {
            if ((area as Map<String, dynamic>)['id'] == areaId) {
              final items = (area['items'] as List?) ?? [];
              for (final item in items) {
                if ((item as Map<String, dynamic>)['id'] == itemId) {
                  final photos = (item['photos'] as List<String>?) ?? [];
                  // Replace the local path with the uploaded URL
                  final lastIndex = photos.length - 1;
                  if (lastIndex >= 0) {
                    photos[lastIndex] = photoUrl;
                  }
                  _inspectionService.updateInspectionItem(itemId,
                      photos: photos);
                  break;
                }
              }
              break;
            }
          }
        });
      } catch (e) {
        // Handle error
      }
    }

    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo added successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _refreshData() async {
    await _loadInspectionData();
  }

  Future<void> _saveDraft() async {
    setState(() {
      _isSaving = true;
    });

    try {
      if (SupabaseService.instance.isAuthenticated) {
        // Real save to Supabase
        final inspectionId = _inspectionData?['id'] as String?;
        if (inspectionId != null) {
          // The individual updates are already handled in onItemStatusChanged, etc.
          // This is just a general save trigger
        }
      }

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
      if (SupabaseService.instance.isAuthenticated) {
        final inspectionId = _inspectionData?['id'] as String?;
        if (inspectionId != null) {
          await _inspectionService.updateInspectionStatus(
              inspectionId, 'completed');
        }
      }

      HapticFeedback.mediumImpact();
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
        final iconSize = ResponsiveHelper.getIconSize(context, small: 60);

        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: AppTheme.successLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(iconSize / 2),
                ),
                child: CustomIconWidget(
                  iconName: 'check_circle',
                  color: AppTheme.successLight,
                  size: iconSize * 0.6,
                ),
              ),
              SizedBox(height: ResponsiveHelper.getSpacing(context, small: 16)),
              Text(
                'Inspection Completed!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveHelper.getSpacing(context, small: 8)),
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
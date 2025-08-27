import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import '../../widgets/database_status_widget.dart';
import '../../widgets/custom_app_bar.dart';
import '../../services/supabase_service.dart';
import '../../services/database_setup_service.dart';
import '../../theme/app_theme.dart';

/// Debug screen for testing database connection and app functionality
class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  bool _isLoading = false;
  String? _testResult;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        title: 'Debug & Testing',
        variant: CustomAppBarVariant.standard,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Database Status Widget
              const DatabaseStatusWidget(),
              
              // Test Actions
              _buildTestActionsCard(),
              
              // Test Results
              if (_testResult != null) _buildTestResultsCard(),
              
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestActionsCard() {
    final theme = Theme.of(context);
    
    return Card(
      margin: EdgeInsets.all(4.w),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.science,
                  color: theme.colorScheme.primary,
                  size: 6.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Test Actions',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 3.h),
            
            _buildTestButton(
              'Test Database Connection',
              Icons.storage,
              _testDatabaseConnection,
            ),
            
            SizedBox(height: 2.h),
            
            _buildTestButton(
              'Test Authentication',
              Icons.login,
              _testAuthentication,
            ),
            
            SizedBox(height: 2.h),
            
            _buildTestButton(
              'Create Sample Inspection',
              Icons.assignment,
              _createSampleInspection,
            ),
            
            SizedBox(height: 2.h),
            
            _buildTestButton(
              'Test Photo Upload',
              Icons.camera_alt,
              _testPhotoUpload,
            ),
            
            SizedBox(height: 2.h),
            
            _buildTestButton(
              'Clear Test Data',
              Icons.delete_sweep,
              _clearTestData,
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(
    String title,
    IconData icon,
    VoidCallback onPressed, {
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : onPressed,
        icon: Icon(icon, size: 5.w),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDestructive 
              ? AppTheme.errorLight 
              : theme.colorScheme.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 2.h),
        ),
      ),
    );
  }

  Widget _buildTestResultsCard() {
    final theme = Theme.of(context);
    
    return Card(
      margin: EdgeInsets.all(4.w),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assignment_turned_in,
                  color: theme.colorScheme.primary,
                  size: 6.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Test Results',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _testResult!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Results copied to clipboard'),
                      ),
                    );
                  },
                  icon: Icon(Icons.copy, size: 5.w),
                ),
              ],
            ),
            
            SizedBox(height: 2.h),
            
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(2.w),
                border: Border.all(
                  color: theme.colorScheme.outline.withAlpha(77),
                ),
              ),
              child: Text(
                _testResult!,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testDatabaseConnection() async {
    setState(() {
      _isLoading = true;
      _testResult = null;
    });

    try {
      final stopwatch = Stopwatch()..start();
      
      // Test connection
      final isConnected = await SupabaseService.instance.testConnection();
      
      // Get database info
      final dbInfo = await DatabaseSetupService.instance.getDatabaseInfo();
      
      stopwatch.stop();
      
      final result = {
        'test': 'Database Connection',
        'timestamp': DateTime.now().toIso8601String(),
        'duration_ms': stopwatch.elapsedMilliseconds,
        'connected': isConnected,
        'database_info': dbInfo,
        'connection_status': SupabaseService.instance.connectionStatus,
      };
      
      setState(() {
        _testResult = _formatJson(result);
        _isLoading = false;
      });
      
      HapticFeedback.lightImpact();
    } catch (e) {
      setState(() {
        _testResult = 'Error: $e';
        _isLoading = false;
      });
      HapticFeedback.heavyImpact();
    }
  }

  Future<void> _testAuthentication() async {
    setState(() {
      _isLoading = true;
      _testResult = null;
    });

    try {
      final client = SupabaseService.instance.client;
      
      final result = {
        'test': 'Authentication',
        'timestamp': DateTime.now().toIso8601String(),
        'current_user': client.auth.currentUser?.toJson(),
        'is_authenticated': SupabaseService.instance.isAuthenticated,
        'session': client.auth.currentSession?.toJson(),
      };
      
      setState(() {
        _testResult = _formatJson(result);
        _isLoading = false;
      });
      
      HapticFeedback.lightImpact();
    } catch (e) {
      setState(() {
        _testResult = 'Error: $e';
        _isLoading = false;
      });
      HapticFeedback.heavyImpact();
    }
  }

  Future<void> _createSampleInspection() async {
    setState(() {
      _isLoading = true;
      _testResult = null;
    });

    try {
      final client = SupabaseService.instance.client;
      
      // Create a test inspection
      final inspection = await client.from('inspections').insert({
        'client_name': 'Test Client ${DateTime.now().millisecondsSinceEpoch}',
        'property_type': 'Residential',
        'inspector_name': 'Test Inspector',
        'inspection_date': DateTime.now().toIso8601String().split('T')[0],
        'property_location': 'Test Address, Test City, TC 12345',
        'status': 'pending',
        'notes': 'Test inspection created from debug screen',
      }).select().single();
      
      final result = {
        'test': 'Create Sample Inspection',
        'timestamp': DateTime.now().toIso8601String(),
        'success': true,
        'inspection': inspection,
      };
      
      setState(() {
        _testResult = _formatJson(result);
        _isLoading = false;
      });
      
      HapticFeedback.lightImpact();
    } catch (e) {
      setState(() {
        _testResult = 'Error: $e';
        _isLoading = false;
      });
      HapticFeedback.heavyImpact();
    }
  }

  Future<void> _testPhotoUpload() async {
    setState(() {
      _isLoading = true;
      _testResult = null;
    });

    try {
      // Simulate photo upload test
      final result = {
        'test': 'Photo Upload',
        'timestamp': DateTime.now().toIso8601String(),
        'note': 'Photo upload functionality would be tested here',
        'storage_bucket': 'inspection-photos',
        'max_file_size': '10MB',
        'supported_formats': ['jpg', 'jpeg', 'png'],
      };
      
      setState(() {
        _testResult = _formatJson(result);
        _isLoading = false;
      });
      
      HapticFeedback.lightImpact();
    } catch (e) {
      setState(() {
        _testResult = 'Error: $e';
        _isLoading = false;
      });
      HapticFeedback.heavyImpact();
    }
  }

  Future<void> _clearTestData() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Test Data'),
        content: const Text(
          'This will delete all test inspections and data. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorLight,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _testResult = null;
    });

    try {
      final client = SupabaseService.instance.client;
      
      // Delete test inspections (those with "Test" in client_name)
      final deletedCount = await client
          .from('inspections')
          .delete()
          .ilike('client_name', '%test%')
          .select()
          .then((data) => data.length);
      
      final result = {
        'test': 'Clear Test Data',
        'timestamp': DateTime.now().toIso8601String(),
        'deleted_inspections': deletedCount,
        'success': true,
      };
      
      setState(() {
        _testResult = _formatJson(result);
        _isLoading = false;
      });
      
      HapticFeedback.lightImpact();
    } catch (e) {
      setState(() {
        _testResult = 'Error: $e';
        _isLoading = false;
      });
      HapticFeedback.heavyImpact();
    }
  }

  String _formatJson(Map<String, dynamic> data) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data);
  }
}
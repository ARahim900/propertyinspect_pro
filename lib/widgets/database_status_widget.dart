import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../services/supabase_service.dart';
import '../services/database_setup_service.dart';
import '../theme/app_theme.dart';

/// Widget to display database connection status and allow testing
class DatabaseStatusWidget extends StatefulWidget {
  const DatabaseStatusWidget({super.key});

  @override
  State<DatabaseStatusWidget> createState() => _DatabaseStatusWidgetState();
}

class _DatabaseStatusWidgetState extends State<DatabaseStatusWidget> {
  bool _isLoading = false;
  Map<String, dynamic>? _connectionStatus;
  Map<String, dynamic>? _databaseInfo;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final status = SupabaseService.instance.connectionStatus;
      final info = await DatabaseSetupService.instance.getDatabaseInfo();
      
      setState(() {
        _connectionStatus = status;
        _databaseInfo = info;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final success = await SupabaseService.instance.testConnection();
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Database connection successful!'),
            backgroundColor: AppTheme.successLight,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Database connection failed!'),
            backgroundColor: AppTheme.errorLight,
          ),
        );
      }
      
      await _checkStatus();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  Icons.storage,
                  color: theme.colorScheme.primary,
                  size: 6.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Database Status',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (_isLoading)
                  SizedBox(
                    width: 5.w,
                    height: 5.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
            
            SizedBox(height: 3.h),
            
            if (_error != null) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.errorLight.withAlpha(26),
                  borderRadius: BorderRadius.circular(2.w),
                  border: Border.all(
                    color: AppTheme.errorLight.withAlpha(77),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.error,
                          color: AppTheme.errorLight,
                          size: 5.w,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Error',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppTheme.errorLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      _error!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.errorLight,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
            ],
            
            if (_connectionStatus != null) ...[
              _buildStatusSection('Connection Status', _connectionStatus!),
              SizedBox(height: 2.h),
            ],
            
            if (_databaseInfo != null) ...[
              _buildStatusSection('Database Info', _databaseInfo!),
              SizedBox(height: 2.h),
            ],
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _testConnection,
                    icon: Icon(Icons.wifi_protected_setup, size: 5.w),
                    label: const Text('Test Connection'),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _checkStatus,
                    icon: Icon(Icons.refresh, size: 5.w),
                    label: const Text('Refresh'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(String title, Map<String, dynamic> data) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.entries.map((entry) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 0.5.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 30.w,
                      child: Text(
                        '${entry.key}:',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface.withAlpha(179),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildValueWidget(entry.value, theme),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildValueWidget(dynamic value, ThemeData theme) {
    Color? textColor;
    IconData? icon;
    
    if (value is bool) {
      textColor = value ? AppTheme.successLight : AppTheme.errorLight;
      icon = value ? Icons.check_circle : Icons.cancel;
    }
    
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 4.w,
            color: textColor,
          ),
          SizedBox(width: 1.w),
        ],
        Expanded(
          child: Text(
            value.toString(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: textColor ?? theme.colorScheme.onSurface,
              fontWeight: value is bool ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
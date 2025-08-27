import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for data backup and recovery
class BackupService {
  static BackupService? _instance;
  static BackupService get instance => _instance ??= BackupService._();
  
  BackupService._();
  
  /// Create full app data backup
  Future<File> createBackup() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/backups');
      
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }
      
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupFile = File('${backupDir.path}/backup_$timestamp.json');
      
      // Collect all app data
      final backupData = await _collectAppData();
      
      // Write to file
      await backupFile.writeAsString(json.encode(backupData));
      
      return backupFile;
    } catch (e) {
      throw Exception('Failed to create backup: $e');
    }
  }
  
  /// Restore from backup file
  Future<void> restoreFromBackup(File backupFile) async {
    try {
      if (!await backupFile.exists()) {
        throw Exception('Backup file does not exist');
      }
      
      final backupContent = await backupFile.readAsString();
      final backupData = json.decode(backupContent) as Map<String, dynamic>;
      
      // Restore data
      await _restoreAppData(backupData);
    } catch (e) {
      throw Exception('Failed to restore backup: $e');
    }
  }
  
  /// Get list of available backups
  Future<List<File>> getAvailableBackups() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/backups');
      
      if (!await backupDir.exists()) {
        return [];
      }
      
      final files = await backupDir.list().toList();
      final backupFiles = files
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .toList();
      
      // Sort by modification date (newest first)
      backupFiles.sort((a, b) => 
          b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      
      return backupFiles;
    } catch (e) {
      return [];
    }
  }
  
  /// Auto backup (called periodically)
  Future<void> performAutoBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastBackup = prefs.getString('last_auto_backup');
      final now = DateTime.now();
      
      // Check if backup is needed (daily)
      if (lastBackup != null) {
        final lastBackupDate = DateTime.parse(lastBackup);
        final daysSinceBackup = now.difference(lastBackupDate).inDays;
        
        if (daysSinceBackup < 1) {
          return; // No backup needed yet
        }
      }
      
      // Create backup
      await createBackup();
      
      // Update last backup timestamp
      await prefs.setString('last_auto_backup', now.toIso8601String());
      
      // Clean old backups (keep only last 7)
      await _cleanOldBackups();
    } catch (e) {
      // Auto backup failed, but don't throw error
      print('Auto backup failed: $e');
    }
  }
  
  /// Collect all app data for backup
  Future<Map<String, dynamic>> _collectAppData() async {
    final prefs = await SharedPreferences.getInstance();
    
    return {
      'version': '1.0.0',
      'timestamp': DateTime.now().toIso8601String(),
      'preferences': prefs.getKeys().fold<Map<String, dynamic>>(
        {},
        (map, key) => map..[key] = prefs.get(key),
      ),
      'app_data': {
        // Add specific app data collections here
        'user_settings': _getUserSettings(),
        'offline_data': await _getOfflineData(),
      },
    };
  }
  
  /// Restore app data from backup
  Future<void> _restoreAppData(Map<String, dynamic> backupData) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Clear existing preferences
    await prefs.clear();
    
    // Restore preferences
    final preferences = backupData['preferences'] as Map<String, dynamic>?;
    if (preferences != null) {
      for (final entry in preferences.entries) {
        final key = entry.key;
        final value = entry.value;
        
        if (value is String) {
          await prefs.setString(key, value);
        } else if (value is int) {
          await prefs.setInt(key, value);
        } else if (value is double) {
          await prefs.setDouble(key, value);
        } else if (value is bool) {
          await prefs.setBool(key, value);
        } else if (value is List<String>) {
          await prefs.setStringList(key, value);
        }
      }
    }
    
    // Restore app-specific data
    final appData = backupData['app_data'] as Map<String, dynamic>?;
    if (appData != null) {
      await _restoreAppSpecificData(appData);
    }
  }
  
  Map<String, dynamic> _getUserSettings() {
    // Collect user-specific settings
    return {
      'theme_mode': 'light',
      'notifications_enabled': true,
      'auto_sync': true,
    };
  }
  
  Future<Map<String, dynamic>> _getOfflineData() async {
    // Collect offline inspection data
    final prefs = await SharedPreferences.getInstance();
    final offlineData = prefs.getString('offline_inspections') ?? '[]';
    
    return {
      'offline_inspections': json.decode(offlineData),
    };
  }
  
  Future<void> _restoreAppSpecificData(Map<String, dynamic> appData) async {
    // Restore offline data
    final offlineData = appData['offline_data'] as Map<String, dynamic>?;
    if (offlineData != null) {
      final prefs = await SharedPreferences.getInstance();
      final inspections = offlineData['offline_inspections'];
      if (inspections != null) {
        await prefs.setString('offline_inspections', json.encode(inspections));
      }
    }
  }
  
  Future<void> _cleanOldBackups() async {
    try {
      final backups = await getAvailableBackups();
      
      // Keep only the 7 most recent backups
      if (backups.length > 7) {
        final oldBackups = backups.skip(7);
        for (final backup in oldBackups) {
          await backup.delete();
        }
      }
    } catch (e) {
      // Cleanup failed, but don't throw error
      print('Backup cleanup failed: $e');
    }
  }
  
  /// Get backup file size in MB
  Future<double> getBackupSize(File backupFile) async {
    try {
      final size = await backupFile.length();
      return size / (1024 * 1024);
    } catch (e) {
      return 0.0;
    }
  }
  
  /// Validate backup file
  Future<bool> isValidBackup(File backupFile) async {
    try {
      final content = await backupFile.readAsString();
      final data = json.decode(content) as Map<String, dynamic>;
      
      // Check required fields
      return data.containsKey('version') && 
             data.containsKey('timestamp') &&
             data.containsKey('preferences');
    } catch (e) {
      return false;
    }
  }
}
import 'dart:async';
import 'package:flutter/foundation.dart';

/// Centralized state management service for app-wide state
class StateService extends ChangeNotifier {
  static StateService? _instance;
  static StateService get instance => _instance ??= StateService._();
  
  StateService._();
  
  // App state
  bool _isLoading = false;
  String? _currentUserId;
  Map<String, dynamic> _userProfile = {};
  List<Map<String, dynamic>> _inspections = [];
  Map<String, dynamic> _appSettings = {};
  
  // Network state
  bool _isOnline = true;
  int _pendingSyncCount = 0;
  
  // UI state
  int _currentBottomNavIndex = 0;
  String _currentScreen = '/';
  
  // Getters
  bool get isLoading => _isLoading;
  String? get currentUserId => _currentUserId;
  Map<String, dynamic> get userProfile => Map.from(_userProfile);
  List<Map<String, dynamic>> get inspections => List.from(_inspections);
  Map<String, dynamic> get appSettings => Map.from(_appSettings);
  bool get isOnline => _isOnline;
  int get pendingSyncCount => _pendingSyncCount;
  int get currentBottomNavIndex => _currentBottomNavIndex;
  String get currentScreen => _currentScreen;
  
  // Loading state management
  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
  
  // User management
  void setCurrentUser(String? userId, Map<String, dynamic>? profile) {
    _currentUserId = userId;
    _userProfile = profile ?? {};
    notifyListeners();
  }
  
  void updateUserProfile(Map<String, dynamic> updates) {
    _userProfile.addAll(updates);
    notifyListeners();
  }
  
  void clearUser() {
    _currentUserId = null;
    _userProfile.clear();
    _inspections.clear();
    notifyListeners();
  }
  
  // Inspection management
  void setInspections(List<Map<String, dynamic>> inspections) {
    _inspections = List.from(inspections);
    notifyListeners();
  }
  
  void addInspection(Map<String, dynamic> inspection) {
    _inspections.insert(0, inspection);
    notifyListeners();
  }
  
  void updateInspection(String inspectionId, Map<String, dynamic> updates) {
    final index = _inspections.indexWhere((i) => i['id'] == inspectionId);
    if (index != -1) {
      _inspections[index].addAll(updates);
      notifyListeners();
    }
  }
  
  void removeInspection(String inspectionId) {
    _inspections.removeWhere((i) => i['id'] == inspectionId);
    notifyListeners();
  }
  
  // Network state management
  void setOnlineStatus(bool online) {
    if (_isOnline != online) {
      _isOnline = online;
      notifyListeners();
    }
  }
  
  void setPendingSyncCount(int count) {
    if (_pendingSyncCount != count) {
      _pendingSyncCount = count;
      notifyListeners();
    }
  }
  
  // Navigation state
  void setBottomNavIndex(int index) {
    if (_currentBottomNavIndex != index) {
      _currentBottomNavIndex = index;
      notifyListeners();
    }
  }
  
  void setCurrentScreen(String screen) {
    if (_currentScreen != screen) {
      _currentScreen = screen;
      notifyListeners();
    }
  }
  
  // App settings
  void updateAppSettings(Map<String, dynamic> settings) {
    _appSettings.addAll(settings);
    notifyListeners();
  }
  
  void setSetting(String key, dynamic value) {
    _appSettings[key] = value;
    notifyListeners();
  }
  
  T? getSetting<T>(String key, [T? defaultValue]) {
    return _appSettings[key] as T? ?? defaultValue;
  }
  
  // Utility methods
  bool get hasUser => _currentUserId != null;
  bool get hasInspections => _inspections.isNotEmpty;
  bool get needsSync => _pendingSyncCount > 0;
  
  Map<String, dynamic> get appState => {
    'isLoading': _isLoading,
    'currentUserId': _currentUserId,
    'userProfile': _userProfile,
    'inspectionCount': _inspections.length,
    'isOnline': _isOnline,
    'pendingSyncCount': _pendingSyncCount,
    'currentScreen': _currentScreen,
  };
  
  // Reset all state (for logout)
  void reset() {
    _isLoading = false;
    _currentUserId = null;
    _userProfile.clear();
    _inspections.clear();
    _pendingSyncCount = 0;
    _currentBottomNavIndex = 0;
    _currentScreen = '/';
    notifyListeners();
  }
}
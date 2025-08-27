
class AppConstants {
  // App Info
  static const String appName = 'PropertyInspect Pro';
  static const String appVersion = '1.0.0';

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'HH:mm';
  static const String displayTimeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';

  // API & Storage
  static const String inspectionPhotosBucket = 'inspection-photos';

  // Business Logic
  static const int maxPhotosPerItem = 5;
  static const int defaultInspectionDuration = 180; // minutes
  static const double defaultTaxRate = 0.05; // 5%

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 8.0;
  static const double largeBorderRadius = 16.0;

  // Inspection Status
  static const String statusPass = 'Pass';
  static const String statusFail = 'Fail';
  static const String statusNA = 'N/A';

  // Schedule Status
  static const String scheduleStatusScheduled = 'scheduled';
  static const String scheduleStatusCompleted = 'completed';
  static const String scheduleStatusCancelled = 'cancelled';

  // Priority Levels
  static const String priorityHigh = 'high';
  static const String priorityMedium = 'medium';
  static const String priorityLow = 'low';

  // Invoice Status
  static const String invoiceStatusDraft = 'draft';
  static const String invoiceStatusSent = 'sent';
  static const String invoiceStatusPaid = 'paid';
  static const String invoiceStatusOverdue = 'overdue';

  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleStaff = 'staff';

  // Property Types
  static const List<String> propertyTypes = [
    'Apartment',
    'Villa',
    'House',
    'Office',
    'Commercial',
    'Warehouse',
    'Shop',
    'Penthouse',
  ];

  // Inspection Categories
  static const List<String> inspectionCategories = [
    'HVAC System',
    'Electrical System',
    'Plumbing',
    'Safety / Utility',
    'Structural',
    'Interior',
    'Exterior',
    'Appliances',
    'Other',
  ];

  // Common inspection areas
  static const List<String> commonAreas = [
    'Living Room',
    'Kitchen',
    'Master Bedroom',
    'Bedroom 1',
    'Bedroom 2',
    'Bathroom 1',
    'Bathroom 2',
    'Balcony',
    'Parking',
    'General Areas',
    'Laundry Room',
    'Storage',
    'Entrance',
  ];

  // File size limits
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB

  // Error Messages
  static const String errorNetwork =
      'Network error. Please check your connection.';
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorAuth = 'Authentication required. Please login.';
  static const String errorPermission =
      'Permission denied. Please check your permissions.';

  // Success Messages
  static const String successSaved = 'Successfully saved!';
  static const String successCreated = 'Successfully created!';
  static const String successUpdated = 'Successfully updated!';
  static const String successDeleted = 'Successfully deleted!';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxDescriptionLength = 500;
  static const int maxCommentLength = 250;
}

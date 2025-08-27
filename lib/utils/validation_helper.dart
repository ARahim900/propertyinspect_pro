import 'dart:io';

/// Comprehensive validation helper for property inspection data
class ValidationHelper {
  /// Validate email format
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email.trim());
  }
  
  /// Validate phone number
  static bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    return phoneRegex.hasMatch(phone.trim());
  }
  
  /// Validate property address
  static String? validatePropertyAddress(String? address) {
    if (address == null || address.trim().isEmpty) {
      return 'Property address is required';
    }
    
    if (address.trim().length < 10) {
      return 'Please enter a complete address';
    }
    
    // Check for basic address components
    final hasNumber = RegExp(r'\d').hasMatch(address);
    if (!hasNumber) {
      return 'Address should include a street number';
    }
    
    return null;
  }
  
  /// Validate inspection date
  static String? validateInspectionDate(DateTime? date) {
    if (date == null) {
      return 'Inspection date is required';
    }
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final inspectionDay = DateTime(date.year, date.month, date.day);
    
    if (inspectionDay.isBefore(today)) {
      return 'Inspection date cannot be in the past';
    }
    
    // Don't allow scheduling too far in advance
    final maxFutureDate = today.add(const Duration(days: 365));
    if (inspectionDay.isAfter(maxFutureDate)) {
      return 'Inspection date cannot be more than 1 year in advance';
    }
    
    return null;
  }
  
  /// Validate inspector name
  static String? validateInspectorName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Inspector name is required';
    }
    
    if (name.trim().length < 2) {
      return 'Inspector name must be at least 2 characters';
    }
    
    // Check for valid name characters
    final nameRegex = RegExp(r'^[a-zA-Z\s\-\.]+$');
    if (!nameRegex.hasMatch(name.trim())) {
      return 'Inspector name contains invalid characters';
    }
    
    return null;
  }
  
  /// Validate property type
  static String? validatePropertyType(String? type) {
    if (type == null || type.trim().isEmpty) {
      return 'Property type is required';
    }
    
    final validTypes = [
      'Residential',
      'Commercial',
      'Multi-family',
      'Industrial',
      'Retail',
      'Office',
      'Warehouse',
      'Mixed-use',
    ];
    
    if (!validTypes.contains(type)) {
      return 'Please select a valid property type';
    }
    
    return null;
  }
  
  /// Validate inspection item status
  static String? validateInspectionStatus(String? status) {
    if (status == null || status.trim().isEmpty) {
      return 'Status is required';
    }
    
    final validStatuses = ['Pass', 'Fail', 'N/A', 'Needs Review'];
    if (!validStatuses.contains(status)) {
      return 'Please select a valid status';
    }
    
    return null;
  }
  
  /// Validate photo file
  static String? validatePhotoFile(File? file) {
    if (file == null) {
      return 'Photo file is required';
    }
    
    if (!file.existsSync()) {
      return 'Photo file does not exist';
    }
    
    // Check file size (max 10MB)
    final fileSizeInMB = file.lengthSync() / (1024 * 1024);
    if (fileSizeInMB > 10) {
      return 'Photo file size must be less than 10MB';
    }
    
    // Check file extension
    final extension = file.path.toLowerCase();
    if (!extension.endsWith('.jpg') && 
        !extension.endsWith('.jpeg') && 
        !extension.endsWith('.png')) {
      return 'Photo must be in JPG, JPEG, or PNG format';
    }
    
    return null;
  }
  
  /// Validate invoice amount
  static String? validateInvoiceAmount(String? amount) {
    if (amount == null || amount.trim().isEmpty) {
      return 'Invoice amount is required';
    }
    
    final numericAmount = double.tryParse(amount.trim());
    if (numericAmount == null) {
      return 'Please enter a valid amount';
    }
    
    if (numericAmount <= 0) {
      return 'Invoice amount must be greater than zero';
    }
    
    if (numericAmount > 999999.99) {
      return 'Invoice amount cannot exceed \$999,999.99';
    }
    
    return null;
  }
  
  /// Validate client name
  static String? validateClientName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Client name is required';
    }
    
    if (name.trim().length < 2) {
      return 'Client name must be at least 2 characters';
    }
    
    if (name.trim().length > 100) {
      return 'Client name cannot exceed 100 characters';
    }
    
    return null;
  }
  
  /// Validate inspection comments
  static String? validateComments(String? comments) {
    if (comments != null && comments.length > 1000) {
      return 'Comments cannot exceed 1000 characters';
    }
    
    return null;
  }
  
  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  /// Validate string length
  static String? validateLength(
    String? value, 
    String fieldName, {
    int? minLength,
    int? maxLength,
  }) {
    if (value == null) return null;
    
    if (minLength != null && value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    
    if (maxLength != null && value.length > maxLength) {
      return '$fieldName cannot exceed $maxLength characters';
    }
    
    return null;
  }
  
  /// Check if inspection is complete
  static bool isInspectionComplete(Map<String, dynamic> inspectionData) {
    // Check required fields
    final requiredFields = [
      'client_name',
      'property_type',
      'inspector_name',
      'inspection_date',
      'property_location',
    ];
    
    for (final field in requiredFields) {
      if (inspectionData[field] == null || 
          inspectionData[field].toString().trim().isEmpty) {
        return false;
      }
    }
    
    return true;
  }
  
  /// Get validation summary for inspection
  static Map<String, List<String>> getInspectionValidationSummary(
    Map<String, dynamic> inspectionData
  ) {
    final errors = <String, List<String>>{};
    
    // Validate each field
    final clientError = validateClientName(inspectionData['client_name']);
    if (clientError != null) {
      errors['client_name'] = [clientError];
    }
    
    final propertyTypeError = validatePropertyType(inspectionData['property_type']);
    if (propertyTypeError != null) {
      errors['property_type'] = [propertyTypeError];
    }
    
    final inspectorError = validateInspectorName(inspectionData['inspector_name']);
    if (inspectorError != null) {
      errors['inspector_name'] = [inspectorError];
    }
    
    final addressError = validatePropertyAddress(inspectionData['property_location']);
    if (addressError != null) {
      errors['property_location'] = [addressError];
    }
    
    return errors;
  }
}
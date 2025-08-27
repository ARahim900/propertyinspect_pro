import 'package:flutter/material.dart';
import '../utils/validation_helper.dart';
import '../services/error_service.dart';

/// Mixin to add validation capabilities to forms
mixin ValidationMixin<T extends StatefulWidget> on State<T> {
  final Map<String, String?> _validationErrors = {};
  final Map<String, bool> _fieldTouched = {};
  
  /// Get validation error for a field
  String? getFieldError(String fieldName) => _validationErrors[fieldName];
  
  /// Check if field has been touched
  bool isFieldTouched(String fieldName) => _fieldTouched[fieldName] ?? false;
  
  /// Mark field as touched
  void touchField(String fieldName) {
    setState(() {
      _fieldTouched[fieldName] = true;
    });
  }
  
  /// Set validation error for a field
  void setFieldError(String fieldName, String? error) {
    setState(() {
      if (error != null) {
        _validationErrors[fieldName] = error;
      } else {
        _validationErrors.remove(fieldName);
      }
    });
  }
  
  /// Clear all validation errors
  void clearValidationErrors() {
    setState(() {
      _validationErrors.clear();
      _fieldTouched.clear();
    });
  }
  
  /// Validate a single field
  String? validateField(String fieldName, String? value, List<String? Function(String?)> validators) {
    try {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) {
          setFieldError(fieldName, error);
          return error;
        }
      }
      
      setFieldError(fieldName, null);
      return null;
    } catch (e, stackTrace) {
      ErrorService.instance.logError(
        'Field validation error',
        error: e,
        stackTrace: stackTrace,
        context: {'fieldName': fieldName, 'value': value},
      );
      
      final error = 'Validation error occurred';
      setFieldError(fieldName, error);
      return error;
    }
  }
  
  /// Validate all fields in a form
  bool validateForm(Map<String, dynamic> formData, Map<String, List<String? Function(String?)>> fieldValidators) {
    bool isValid = true;
    
    try {
      for (final entry in fieldValidators.entries) {
        final fieldName = entry.key;
        final validators = entry.value;
        final value = formData[fieldName]?.toString();
        
        final error = validateField(fieldName, value, validators);
        if (error != null) {
          isValid = false;
        }
      }
      
      return isValid;
    } catch (e, stackTrace) {
      ErrorService.instance.logError(
        'Form validation error',
        error: e,
        stackTrace: stackTrace,
        context: {'formData': formData.toString()},
      );
      
      return false;
    }
  }
  
  /// Get all validation errors
  Map<String, String> get validationErrors => Map.from(_validationErrors.where((key, value) => value != null));
  
  /// Check if form has any errors
  bool get hasValidationErrors => _validationErrors.values.any((error) => error != null);
  
  /// Get error count
  int get errorCount => _validationErrors.values.where((error) => error != null).length;
  
  /// Create a validated TextFormField
  Widget buildValidatedTextField({
    required String fieldName,
    required TextEditingController controller,
    required String labelText,
    required List<String? Function(String?)> validators,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    Widget? prefixIcon,
    String? hintText,
    int? maxLines = 1,
    int? maxLength,
    bool enabled = true,
    void Function(String)? onChanged,
    void Function()? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        errorText: isFieldTouched(fieldName) ? getFieldError(fieldName) : null,
        errorMaxLines: 2,
      ),
      validator: (value) => validateField(fieldName, value, validators),
      onChanged: (value) {
        touchField(fieldName);
        validateField(fieldName, value, validators);
        onChanged?.call(value);
      },
      onTap: () {
        touchField(fieldName);
        onTap?.call();
      },
    );
  }
  
  /// Create a validated DropdownButtonFormField
  Widget buildValidatedDropdown<V>({
    required String fieldName,
    required V? value,
    required List<DropdownMenuItem<V>> items,
    required String labelText,
    required List<String? Function(V?)> validators,
    required void Function(V?) onChanged,
    String? hintText,
    bool enabled = true,
  }) {
    return DropdownButtonFormField<V>(
      value: value,
      items: items,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorText: isFieldTouched(fieldName) ? getFieldError(fieldName) : null,
        errorMaxLines: 2,
      ),
      validator: (value) => validateField(fieldName, value?.toString(), validators.cast<String? Function(String?)>()),
      onChanged: enabled ? (value) {
        touchField(fieldName);
        validateField(fieldName, value?.toString(), validators.cast<String? Function(String?)>());
        onChanged(value);
      } : null,
    );
  }
  
  /// Show validation summary dialog
  void showValidationSummary(BuildContext context) {
    if (!hasValidationErrors) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Validation Errors'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Please fix the following errors:'),
            const SizedBox(height: 16),
            ...validationErrors.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${entry.key}: ${entry.value}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
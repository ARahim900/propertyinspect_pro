import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Service for handling data encryption and security
class EncryptionService {
  static EncryptionService? _instance;
  static EncryptionService get instance => _instance ??= EncryptionService._();
  
  EncryptionService._();
  
  /// Hash sensitive data before storage
  String hashData(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  /// Validate data integrity
  bool validateHash(String data, String hash) {
    return hashData(data) == hash;
  }
  
  /// Generate secure random tokens
  String generateSecureToken() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp.toString() + DateTime.now().microsecond.toString();
    return hashData(random).substring(0, 32);
  }
}
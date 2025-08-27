import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import './error_service.dart';
import './performance_service.dart';

/// Advanced photo management service with compression and metadata
class PhotoService {
  static PhotoService? _instance;
  static PhotoService get instance => _instance ??= PhotoService._();
  
  PhotoService._();
  
  final ImagePicker _picker = ImagePicker();
  
  /// Take photo with camera
  Future<File?> takePhoto({
    bool compress = true,
    int quality = 85,
  }) async {
    PerformanceService.instance.startOperation('take_photo');
    
    try {
      // Check camera permission
      final permission = await Permission.camera.request();
      if (!permission.isGranted) {
        throw Exception('Camera permission denied');
      }
      
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: quality,
        preferredCameraDevice: CameraDevice.rear,
      );
      
      if (photo == null) {
        PerformanceService.instance.endOperation('take_photo');
        return null;
      }
      
      File photoFile = File(photo.path);
      
      if (compress) {
        photoFile = await _compressImage(photoFile, quality);
      }
      
      // Add metadata
      await _addPhotoMetadata(photoFile);
      
      // Track photo capture
      PerformanceService.instance.trackPhotoCapture(
        context: 'camera',
        photoCount: 1,
        totalSizeMB: getFileSizeInMB(photoFile),
      );
      
      PerformanceService.instance.endOperation('take_photo');
      return photoFile;
    } catch (e, stackTrace) {
      PerformanceService.instance.endOperation('take_photo');
      
      ErrorService.instance.logError(
        'Failed to take photo',
        error: e,
        stackTrace: stackTrace,
        context: {'quality': quality, 'compress': compress},
      );
      
      throw Exception('Failed to take photo: $e');
    }
  }
  
  /// Pick photo from gallery
  Future<File?> pickFromGallery({
    bool compress = true,
    int quality = 85,
  }) async {
    try {
      final permission = await Permission.photos.request();
      if (!permission.isGranted) {
        throw Exception('Photo access permission denied');
      }
      
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: quality,
      );
      
      if (photo == null) return null;
      
      File photoFile = File(photo.path);
      
      if (compress) {
        photoFile = await _compressImage(photoFile, quality);
      }
      
      return photoFile;
    } catch (e) {
      throw Exception('Failed to pick photo: $e');
    }
  }
  
  /// Pick multiple photos
  Future<List<File>> pickMultiplePhotos({
    bool compress = true,
    int quality = 85,
    int maxImages = 10,
  }) async {
    try {
      final permission = await Permission.photos.request();
      if (!permission.isGranted) {
        throw Exception('Photo access permission denied');
      }
      
      final List<XFile> photos = await _picker.pickMultiImage(
        imageQuality: quality,
        limit: maxImages,
      );
      
      List<File> photoFiles = [];
      
      for (final photo in photos) {
        File photoFile = File(photo.path);
        
        if (compress) {
          photoFile = await _compressImage(photoFile, quality);
        }
        
        photoFiles.add(photoFile);
      }
      
      return photoFiles;
    } catch (e) {
      throw Exception('Failed to pick photos: $e');
    }
  }
  
  /// Compress image file
  Future<File> _compressImage(File file, int quality) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: 1920,
        minHeight: 1080,
        format: CompressFormat.jpeg,
      );
      
      return compressedFile ?? file;
    } catch (e) {
      // Return original file if compression fails
      return file;
    }
  }
  
  /// Add metadata to photo (timestamp, location, etc.)
  Future<void> _addPhotoMetadata(File photo) async {
    try {
      // Add timestamp to filename or EXIF data
      final timestamp = DateTime.now().toIso8601String();
      // Implementation depends on chosen metadata library
    } catch (e) {
      // Metadata addition failed, but photo is still valid
    }
  }
  
  /// Get photo file size in MB
  double getFileSizeInMB(File file) {
    final bytes = file.lengthSync();
    return bytes / (1024 * 1024);
  }
  
  /// Validate photo file
  bool isValidPhoto(File file) {
    final extension = file.path.toLowerCase();
    return extension.endsWith('.jpg') || 
           extension.endsWith('.jpeg') || 
           extension.endsWith('.png');
  }
  
  /// Show photo picker dialog
  Future<File?> showPhotoPickerDialog(BuildContext context) async {
    return showModalBottomSheet<File?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                final photo = await takePhoto();
                Navigator.pop(context, photo);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final photo = await pickFromGallery();
                Navigator.pop(context, photo);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
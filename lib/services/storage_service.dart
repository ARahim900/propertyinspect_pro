import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './auth_service.dart';
import './supabase_service.dart';

class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();

  StorageService._();

  final SupabaseClient _client = SupabaseService.instance.client;
  final ImagePicker _picker = ImagePicker();

  static const String inspectionPhotosBucket = 'inspection-photos';

  // Upload photo from camera or gallery
  Future<String> uploadInspectionPhoto({
    required String inspectionId,
    required String areaId,
    required String itemId,
    bool fromCamera = false,
  }) async {
    final user = AuthService.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Request permissions
      if (fromCamera) {
        final cameraPermission = await Permission.camera.request();
        if (!cameraPermission.isGranted) {
          throw Exception('Camera permission required');
        }
      } else {
        final photosPermission = await Permission.photos.request();
        if (!photosPermission.isGranted) {
          throw Exception('Photos permission required');
        }
      }

      // Pick image
      final XFile? image = fromCamera
          ? await _picker.pickImage(source: ImageSource.camera)
          : await _picker.pickImage(source: ImageSource.gallery);

      if (image == null) {
        throw Exception('No image selected');
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'photo_${timestamp}_${itemId.substring(0, 8)}';
      final filePath = '${user.id}/$inspectionId/$areaId/$filename.jpg';

      // Upload to Supabase Storage
      final file = File(image.path);
      await _client.storage.from(inspectionPhotosBucket).upload(filePath, file);

      return filename;
    } catch (error) {
      throw Exception('Failed to upload photo: $error');
    }
  }

  // Get photo URL
  String getPhotoUrl(
      String filename, String userId, String inspectionId, String areaId) {
    final filePath = '$userId/$inspectionId/$areaId/$filename.jpg';
    return _client.storage.from(inspectionPhotosBucket).getPublicUrl(filePath);
  }

  // Download photo
  Future<Uint8List> downloadPhoto(String filename, String userId,
      String inspectionId, String areaId) async {
    try {
      final filePath = '$userId/$inspectionId/$areaId/$filename.jpg';
      final response =
          await _client.storage.from(inspectionPhotosBucket).download(filePath);

      return response;
    } catch (error) {
      throw Exception('Failed to download photo: $error');
    }
  }

  // Delete photo
  Future<void> deletePhoto(String filename, String userId, String inspectionId,
      String areaId) async {
    try {
      final filePath = '$userId/$inspectionId/$areaId/$filename.jpg';
      await _client.storage.from(inspectionPhotosBucket).remove([filePath]);
    } catch (error) {
      throw Exception('Failed to delete photo: $error');
    }
  }

  // Upload multiple photos
  Future<List<String>> uploadMultiplePhotos({
    required String inspectionId,
    required String areaId,
    required String itemId,
    int maxImages = 5,
  }) async {
    final user = AuthService.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final photosPermission = await Permission.photos.request();
      if (!photosPermission.isGranted) {
        throw Exception('Photos permission required');
      }

      final List<XFile> images = await _picker.pickMultiImage(limit: maxImages);

      if (images.isEmpty) {
        throw Exception('No images selected');
      }

      final List<String> uploadedFilenames = [];

      for (int i = 0; i < images.length; i++) {
        try {
          final timestamp = DateTime.now().millisecondsSinceEpoch + i;
          final filename = 'photo_${timestamp}_${itemId.substring(0, 8)}';
          final filePath = '${user.id}/$inspectionId/$areaId/$filename.jpg';

          final file = File(images[i].path);
          await _client.storage
              .from(inspectionPhotosBucket)
              .upload(filePath, file);

          uploadedFilenames.add(filename);
        } catch (error) {
          // Continue uploading other images even if one fails
          continue;
        }
      }

      if (uploadedFilenames.isEmpty) {
        throw Exception('Failed to upload any photos');
      }

      return uploadedFilenames;
    } catch (error) {
      throw Exception('Failed to upload photos: $error');
    }
  }

  // Get all photos for an inspection item
  Future<List<String>> getInspectionItemPhotos({
    required String userId,
    required String inspectionId,
    required String areaId,
  }) async {
    try {
      final folderPath = '$userId/$inspectionId/$areaId/';
      final response = await _client.storage
          .from(inspectionPhotosBucket)
          .list(path: folderPath);

      return response.map((file) => file.name.replaceAll('.jpg', '')).toList();
    } catch (error) {
      throw Exception('Failed to get photos: $error');
    }
  }

  // Clear all photos for an inspection
  Future<void> clearInspectionPhotos(String inspectionId) async {
    final user = AuthService.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final folderPath = '${user.id}/$inspectionId/';
      final response = await _client.storage
          .from(inspectionPhotosBucket)
          .list(path: folderPath);

      if (response.isNotEmpty) {
        final filePaths =
            response.map((file) => '$folderPath${file.name}').toList();
        await _client.storage.from(inspectionPhotosBucket).remove(filePaths);
      }
    } catch (error) {
      throw Exception('Failed to clear photos: $error');
    }
  }

  // Check if photo exists
  Future<bool> photoExists(String filename, String userId, String inspectionId,
      String areaId) async {
    try {
      final filePath = '$userId/$inspectionId/$areaId/$filename.jpg';
      await _client.storage.from(inspectionPhotosBucket).download(filePath);
      return true;
    } catch (error) {
      return false;
    }
  }

  // Get storage usage info
  Future<Map<String, dynamic>> getStorageInfo() async {
    final user = AuthService.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final response = await _client.storage
          .from(inspectionPhotosBucket)
          .list(path: '${user.id}/');

      int totalFiles = 0;
      double totalSize = 0;

      void countFiles(List<FileObject> files) {
        for (final file in files) {
          totalFiles++;
          totalSize += file.metadata?['size'] ?? 0;
        }
      }

      countFiles(response);

      return {
        'totalFiles': totalFiles,
        'totalSize': totalSize,
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      };
    } catch (error) {
      return {
        'totalFiles': 0,
        'totalSize': 0,
        'totalSizeMB': '0.00',
      };
    }
  }
}

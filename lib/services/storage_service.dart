import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer' as developer;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // Upload cat photo
  Future<String?> uploadCatPhoto(String catId, String householdId, XFile imageFile) async {
    try {
      final file = File(imageFile.path);
      final fileName = '$catId.jpg';
      final path = 'cat_photos/$householdId/$fileName';
      
      final ref = _storage.ref().child(path);
      
      // Upload file
      final uploadTask = await ref.putFile(
        file,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'catId': catId,
            'householdId': householdId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );
      
      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      developer.log('Cat photo uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      developer.log('Error uploading cat photo: $e');
      throw Exception('Erro ao fazer upload da foto: $e');
    }
  }

  // Delete cat photo
  Future<void> deleteCatPhoto(String photoUrl) async {
    try {
      if (photoUrl.isEmpty) return;
      
      // Extract path from URL
      final uri = Uri.parse(photoUrl);
      final path = uri.pathSegments.join('/');
      
      // Remove leading 'o/' from path if present
      final cleanPath = path.startsWith('o/') ? path.substring(2) : path;
      
      final ref = _storage.ref().child(cleanPath);
      await ref.delete();
      
      developer.log('Cat photo deleted successfully: $photoUrl');
    } catch (e) {
      developer.log('Error deleting cat photo: $e');
      // Don't throw exception for delete failures - photo might not exist
    }
  }

  // Pick image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      developer.log('Error picking image from gallery: $e');
      return null;
    }
  }

  // Pick image from camera
  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      developer.log('Error picking image from camera: $e');
      return null;
    }
  }

  // Show image picker options
  Future<XFile?> showImagePickerOptions() async {
    // This would typically be called from a UI context
    // For now, default to gallery
    return await pickImageFromGallery();
  }

  // Get image picker source options
  List<ImageSource> getImageSourceOptions() {
    return [ImageSource.gallery, ImageSource.camera];
  }

  // Validate image file
  bool validateImageFile(XFile file) {
    try {
      final fileSize = File(file.path).lengthSync();
      const maxSize = 5 * 1024 * 1024; // 5MB
      
      if (fileSize > maxSize) {
        developer.log('Image file too large: $fileSize bytes');
        return false;
      }
      
      // Check file extension
      final extension = file.path.toLowerCase().split('.').last;
      const allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];
      
      if (!allowedExtensions.contains(extension)) {
        developer.log('Invalid image format: $extension');
        return false;
      }
      
      return true;
    } catch (e) {
      developer.log('Error validating image file: $e');
      return false;
    }
  }

  // Get storage usage for household
  Future<int> getHouseholdStorageUsage(String householdId) async {
    try {
      final ref = _storage.ref().child('cat_photos/$householdId');
      final listResult = await ref.listAll();
      
      int totalSize = 0;
      for (final item in listResult.items) {
        final metadata = await item.getMetadata();
        totalSize += metadata.size ?? 0;
      }
      
      return totalSize;
    } catch (e) {
      developer.log('Error getting storage usage: $e');
      return 0;
    }
  }

  // Clean up orphaned photos
  Future<void> cleanupOrphanedPhotos(String householdId, List<String> validCatIds) async {
    try {
      final ref = _storage.ref().child('cat_photos/$householdId');
      final listResult = await ref.listAll();
      
      for (final item in listResult.items) {
        final fileName = item.name.split('.').first; // Remove .jpg extension
        if (!validCatIds.contains(fileName)) {
          await item.delete();
          developer.log('Deleted orphaned photo: ${item.name}');
        }
      }
    } catch (e) {
      developer.log('Error cleaning up orphaned photos: $e');
    }
  }
}

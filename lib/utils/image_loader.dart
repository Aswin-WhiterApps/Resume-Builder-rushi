import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Utility class for safe image loading operations
class ImageLoader {
  /// Safely loads an image from a file path with comprehensive error handling
  static Future<Widget> loadFileImage(
    String imagePath, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) async {
    if (imagePath.isEmpty) {
      return errorWidget ?? _buildDefaultErrorWidget();
    }

    try {
      final file = File(imagePath);
      
      // Check if file exists before attempting to load
      if (!await file.exists()) {
        debugPrint('Image file does not exist: $imagePath');
        return errorWidget ?? _buildDefaultErrorWidget();
      }

      // Additional check for file size to prevent loading corrupted files
      final fileSize = await file.length();
      if (fileSize == 0) {
        debugPrint('Image file is empty: $imagePath');
        return errorWidget ?? _buildDefaultErrorWidget();
      }

      // If file is valid, load with error handling
      return Image.file(
        file,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading image file $imagePath: $error');
          return errorWidget ?? _buildDefaultErrorWidget();
        },
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (frame == null) {
            return placeholder ?? _buildDefaultLoadingWidget();
          }
          return child;
        },
      );
    } catch (e) {
      debugPrint('Exception loading image $imagePath: $e');
      return errorWidget ?? _buildDefaultErrorWidget();
    }
  }

  /// Safely loads an image from network with comprehensive error handling
  static Widget loadNetworkImage(
    String imageUrl, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    if (imageUrl.isEmpty) {
      return errorWidget ?? _buildDefaultErrorWidget();
    }

    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Error loading network image $imageUrl: $error');
        return errorWidget ?? _buildDefaultErrorWidget();
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? _buildDefaultLoadingWidget();
      },
    );
  }

  /// Safely loads image bytes for MemoryImage usage
  static Future<Uint8List?> loadImageBytes(String imagePath) async {
    if (imagePath.isEmpty) return null;

    try {
      final file = File(imagePath);
      
      // Check if file exists
      if (!await file.exists()) {
        debugPrint('Image file does not exist: $imagePath');
        return null;
      }

      // Check file size
      final fileSize = await file.length();
      if (fileSize == 0) {
        debugPrint('Image file is empty: $imagePath');
        return null;
      }

      // Read file bytes with error handling
      return await file.readAsBytes();
    } catch (e) {
      debugPrint('Exception reading image bytes $imagePath: $e');
      return null;
    }
  }

  /// Safely creates a MemoryImage from file path
  static Future<MemoryImage?> createMemoryImage(String imagePath) async {
    final bytes = await loadImageBytes(imagePath);
    return bytes != null ? MemoryImage(bytes) : null;
  }

  /// Gets the proper cache directory path
  static Future<String> getCacheImagePath(String filename) async {
    try {
      final Directory cacheDir = await getApplicationCacheDirectory();
      return '${cacheDir.path}/$filename';
    } catch (e) {
      debugPrint('Error getting cache directory: $e');
      // Fallback to a temporary directory
      final tempDir = Directory.systemTemp;
      return '${tempDir.path}/$filename';
    }
  }

  /// Validates if an image file is valid and readable
  static Future<bool> isImageFileValid(String imagePath) async {
    if (imagePath.isEmpty) return false;

    try {
      final file = File(imagePath);
      
      // Check existence
      if (!await file.exists()) return false;
      
      // Check file size
      final fileSize = await file.length();
      if (fileSize == 0) return false;
      
      // Try to read first few bytes to verify it's a valid image
      final bytes = await file.openRead(0, 10).first;
      if (bytes.isEmpty) return false;
      
      // Basic image signature checks
      return _isValidImageSignature(bytes);
    } catch (e) {
      debugPrint('Error validating image file $imagePath: $e');
      return false;
    }
  }

  /// Checks if bytes start with valid image signatures
  static bool _isValidImageSignature(List<int> bytes) {
    if (bytes.length < 2) return false;
    
    // JPEG signature (FF D8)
    if (bytes[0] == 0xFF && bytes[1] == 0xD8) return true;
    
    // PNG signature (89 50 4E 47)
    if (bytes.length >= 4 &&
        bytes[0] == 0x89 && bytes[1] == 0x50 && 
        bytes[2] == 0x4E && bytes[3] == 0x47) return true;
    
    // WebP signature (52 49 46 46 ... 57 45 42 50)
    if (bytes.length >= 8 &&
        bytes[0] == 0x52 && bytes[1] == 0x49 && 
        bytes[2] == 0x46 && bytes[3] == 0x46 &&
        bytes[8] == 0x57 && bytes[9] == 0x45 && 
        bytes[10] == 0x42 && bytes[11] == 0x50) return true;
    
    return false;
  }

  /// Default error widget for failed image loads
  static Widget _buildDefaultErrorWidget() {
    return Container(
      color: Colors.grey[300],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            size: 50,
            color: Colors.grey,
          ),
          SizedBox(height: 8),
          Text(
            'Image unavailable',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Default loading widget for image loading
  static Widget _buildDefaultLoadingWidget() {
    return Container(
      color: Colors.grey[100],
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      ),
    );
  }

  /// Cleans up invalid image files from cache
  static Future<void> cleanupInvalidCacheImages() async {
    try {
      final cacheDir = await getApplicationCacheDirectory();
      final files = await cacheDir.list().toList();
      
      for (final file in files) {
        if (file is File && _isImageFile(file.path)) {
          final isValid = await isImageFileValid(file.path);
          if (!isValid) {
            try {
              await file.delete();
              debugPrint('Deleted invalid cache image: ${file.path}');
            } catch (e) {
              debugPrint('Error deleting invalid image ${file.path}: $e');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error during cache cleanup: $e');
    }
  }

  /// Checks if a file path likely points to an image based on extension
  static bool _isImageFile(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }
}

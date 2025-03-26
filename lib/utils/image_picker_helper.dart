import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_html/html.dart' as html;

class ImagePickerHelper {
  // Pick image from gallery
  static Future<ImageResult?> pickImage() async {
    try {
      if (kIsWeb) {
        // Web implementation
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );

        if (result == null || result.files.isEmpty) return null;

        final file = result.files.first;
        if (file.bytes == null) return null;

        return ImageResult(
          fileName: file.name,
          bytes: file.bytes!,
          mimeType: _getMimeType(file.name),
        );
      } else {
        // Mobile implementation
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );

        if (pickedFile == null) return null;

        final bytes = await pickedFile.readAsBytes();
        
        return ImageResult(
          fileName: pickedFile.name,
          bytes: bytes,
          mimeType: _getMimeType(pickedFile.name),
          path: pickedFile.path,
        );
      }
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  // Take photo with camera
  static Future<ImageResult?> captureImage({int imageQuality = 80}) async {
    try {
      if (kIsWeb) {
        // Web camera implementation
        final completer = Completer<ImageResult?>();
        
        // Create file input element
        final inputElement = html.FileUploadInputElement()..accept = 'image/*';
        inputElement.click();
        
        // Listen for camera capture
        inputElement.onChange.listen((event) async {
          final files = inputElement.files;
          if (files != null && files.isNotEmpty) {
            final file = files[0];
            final reader = html.FileReader();
            
            reader.onLoadEnd.listen((event) {
              final result = reader.result;
              if (result is Uint8List) {
                completer.complete(ImageResult(
                  fileName: file.name,
                  bytes: result,
                  mimeType: file.type,
                ));
              } else {
                completer.complete(null);
              }
            });
            
            reader.readAsArrayBuffer(file);
          } else {
            completer.complete(null);
          }
        });
        
        return completer.future;
      } else {
        // Mobile camera implementation
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: imageQuality,
        );

        if (pickedFile == null) return null;

        final bytes = await pickedFile.readAsBytes();
        
        return ImageResult(
          fileName: pickedFile.name,
          bytes: bytes,
          mimeType: _getMimeType(pickedFile.name),
          path: pickedFile.path,
        );
      }
    } catch (e) {
      print('Error capturing image: $e');
      return null;
    }
  }
  
  // Helper to get MIME type from filename
  static String _getMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
  
  // Convert bytes to File (for mobile platforms)
  static Future<File> bytesToFile(Uint8List bytes, String fileName) async {
    if (kIsWeb) {
      throw UnsupportedError('bytesToFile is not supported on Web');
    }
    
    final tempDir = await Directory.systemTemp.createTemp();
    final tempFile = File('${tempDir.path}/$fileName');
    await tempFile.writeAsBytes(bytes);
    return tempFile;
  }
}

class ImageResult {
  final String fileName;
  final Uint8List bytes;
  final String mimeType;
  final String? path;  // Only available on mobile

  ImageResult({
    required this.fileName,
    required this.bytes,
    required this.mimeType,
    this.path,
  });
  
  Future<File?> toFile() async {
    if (kIsWeb) return null;
    
    if (path != null) {
      return File(path!);
    } else {
      return await ImagePickerHelper.bytesToFile(bytes, fileName);
    }
  }
}
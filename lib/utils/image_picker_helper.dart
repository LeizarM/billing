// lib/utils/image_picker_helper.dart
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';

class ImagePickerHelper {
  static Future<ImageResult?> pickImage() async {
    try {
      if (kIsWeb) {
        // Implementación para web
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
          mimeType: 'image/jpeg',
        );
      } else {
        // Implementación para móvil
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
          mimeType: 'image/jpeg',
        );
      }
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }
}

class ImageResult {
  final String fileName;
  final Uint8List bytes;
  final String mimeType;

  ImageResult({
    required this.fileName,
    required this.bytes,
    required this.mimeType,
  });
}
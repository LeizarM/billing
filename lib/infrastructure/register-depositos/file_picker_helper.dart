// file_picker_helper.dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class FilePickerHelper {
  static FilePickerHelper? _instance;
  static FilePicker? _filePicker;

  FilePickerHelper._();

  static Future<FilePickerHelper> getInstance() async {
    if (_instance == null) {
      _instance = FilePickerHelper._();
      if (kIsWeb) {
        _filePicker = FilePicker.platform;
        // Forzar inicialización
        try {
          await _filePicker?.clearTemporaryFiles();
        } catch (e) {
          print('Error initializing FilePicker: $e');
        }
      }
    }
    return _instance!;
  }

  Future<PlatformFile?> pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.first;
      }
    } catch (e) {
      print('Error picking file: $e');
      rethrow;
    }
    return null;
  }
}
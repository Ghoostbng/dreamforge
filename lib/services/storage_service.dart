// lib/services/storage_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class StorageService {
  Future<Directory> get _localDirectory async {
    if (kIsWeb) {
      // Sur le web, utiliser un chemin temporaire
      return Directory.systemTemp;
    } else {
      return getApplicationDocumentsDirectory();
    }
  }

  Future<File?> saveBytesToFile(Uint8List bytes, String filename) async {
    try {
      final directory = await _localDirectory;
      final filePath = '${directory.path}/$filename';
      final file = File(filePath);
      
      await file.create(recursive: true);
      await file.writeAsBytes(bytes);
      
      return file;
    } catch (e) {
      // Log error instead of using print
      debugPrint('Erreur saveBytesToFile: $e');
      return null;
    }
  }

  Future<List<File>> listFiles() async {
    try {
      final directory = await _localDirectory;
      if (await directory.exists()) {
        final files = await directory.list().toList();
        return files.whereType<File>().toList();
      }
      return [];
    } catch (e) {
      // Log error instead of using print
      debugPrint('Erreur listFiles: $e');
      return [];
    }
  }

  Future<String> getFilePath(String filename) async {
    final directory = await _localDirectory;
    return '${directory.path}/$filename';
  }
}
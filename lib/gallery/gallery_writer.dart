import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path_lib;

class GalleryWriter {
  static GalleryWriter? _instance;

  static GalleryWriter get instance => _instance ??= GalleryWriter();

  void writeImages(List<String> source, String destination) async {
    final Directory externalStorageDir = (await getExternalStorageDirectory())!;
    for (var path in source) {
      final imageType = path_lib.extension(path);

      String filename = '${source.indexOf(path)}.$imageType';

      final copiedFile = File(path)
          .copySync('${externalStorageDir.path}/$destination/$filename');

      debugPrint('Image copied: ${copiedFile.path}');
    }
  }

  void createDirectory(String path) async {
    final Directory externalStorageDir = (await getExternalStorageDirectory())!;
    Directory(path_lib.join(externalStorageDir.path, path)).createSync();
    debugPrint('Directory created: ${externalStorageDir.path}/$path');
  }

  String generateBatchPath() {
    final now = DateTime.now();
    var path =
        'Cao-nalyzer ${now.year}-${now.month}-${now.day} ${now.hour}:${now.minute}';

    // if exists, append duplicate number
    var duplicateNumber = 1;
    while (Directory(path).existsSync()) {
      path =
          'Cao-nalyzer ${now.year}-${now.month}-${now.day} ${now.hour}:${now.minute} ($duplicateNumber)';
      duplicateNumber++;
    }

    return path;
  }

  Future<String> appendImage(String source, String destinationDir) async {
    final Directory externalStorageDir = (await getExternalStorageDirectory())!;

    final fileType = path_lib.extension(source);
    final filesCount = (await _getFiles(destinationDir)).length;
    final filename = '$filesCount$fileType';

    final copiedFile = File(source)
        .copySync('${externalStorageDir.path}/$destinationDir/$filename');

    debugPrint('Image copied: ${copiedFile.path}');

    return copiedFile.path;
  }

  Future<List<FileSystemEntity>> _getFiles(String path) async {
    final Directory externalStorageDir = (await getExternalStorageDirectory())!;
    final dir = Directory('${externalStorageDir.path}/$path');

    return dir.listSync();
  }

  void removeImage(String source) {
    File(source).deleteSync();
  }
}

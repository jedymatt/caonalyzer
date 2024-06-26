import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path_lib;

class GalleryWriter {
  static void createDirectory(String path) async {
    Directory(path).createSync();
    debugPrint('Directory created: $path');
  }

  static void deleteDirectory(String path) async {
    Directory(path).deleteSync(recursive: true);
    debugPrint('Directory deleted: $path');
  }

  static Future<String> generateBatchPath(DateTime dateTime) async {
    final Directory storageDir = await getApplicationDocumentsDirectory();

    final dirPath = path_lib.join(storageDir.path, 'batches');

    String batchDirName =
        'Cao-nalyzer ${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute}';

    final glob = Glob(
        path_lib.join(Glob.quote(dirPath), '${Glob.quote(batchDirName)}*'));

    final existingBatchesCount = glob.listSync().length;

    if (existingBatchesCount > 0) {
      batchDirName = '$batchDirName ($existingBatchesCount)';
    }

    return path_lib.join(dirPath, batchDirName);
  }

  static Future<void> appendImages(
      List<String> sources, String destinationDir) async {
    for (var i = 0; i < sources.length; i++) {
      var newSourcePath =
          path_lib.join(destinationDir, path_lib.basename(sources[i]));

      await File(sources[i]).copy(newSourcePath);
    }
  }

  static void removeImages(List<String> images) {
    for (var image in images) {
      File(image).deleteSync();
    }
  }
}

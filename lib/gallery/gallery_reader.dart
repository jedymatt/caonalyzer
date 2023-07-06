import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path_lib;

class GalleryReader {
  static Future<List<File>> getImages(String path) async {
    final glob = Glob(path_lib.join(
      Glob.quote(path),
      '*.{jpg,jpeg,png}',
    ));

    return glob.listSync().map((e) => File(e.path)).toList();
  }

  static Future<List<String>> getBatchPaths() async {
    final Directory externalStorageDir =
        await getApplicationDocumentsDirectory();

    final dir = Directory(path_lib.join(externalStorageDir.path, 'batches'));

    if (!dir.existsSync()) dir.createSync();

    return dir
        .listSync()
        .reversed
        .map((e) => e.path)
        .where((element) => Directory(element).listSync().isNotEmpty)
        .toList();
  }

  static bool batchExists(String batchPath) {
    return Directory(batchPath).existsSync();
  }
}

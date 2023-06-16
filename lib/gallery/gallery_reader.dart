import 'dart:io';

import 'package:caonalyzer/gallery/models/batch.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path_lib;

class GalleryReader {
  static Future<List<File>> getImages(String path) async {
    final dir = Directory(path);

    return dir.listSync().map((e) => File(e.path)).toList();
  }

  static Future<List<String>> getBatchPaths() async {
    final Directory externalStorageDir = (await getExternalStorageDirectory())!;

    final dir = Directory(externalStorageDir.path);

    return dir
        .listSync()
        .reversed
        .map((e) => e.path)
        .where((element) => Directory(element).listSync().isNotEmpty)
        .toList();
  }

  static List<String> getImagesFromBatch(String batchPath) {
    // batchPath add escape character for regex characters
    batchPath = batchPath.replaceAllMapped(
      RegExp(r'([\\^$*+?{}\[\]().])'),
      (match) => '\\${match.group(1)}',
    );
    final imageFile = Glob(path_lib.join(batchPath, '*.{jpg,jpeg,png}'));

    return imageFile.listSync().map((e) => e.path).toList();
  }

  static Future<List<Batch>> getBatches() async {
    final Directory externalStorageDir = (await getExternalStorageDirectory())!;

    final dir = Directory(externalStorageDir.path);

    return dir
        .listSync()
        .reversed
        // where directory is not empty
        .where((element) => Directory(element.path).listSync().isNotEmpty)
        .map((e) => Batch(
              title: path_lib.basename(e.path),
              dirPath: e.path,
            ))
        .toList();
  }
}

import 'dart:io';

import 'package:caonalyzer/gallery/models/batch.dart';
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
    final dir = Directory(batchPath);

    return dir.listSync().map((e) => e.path).toList();
  }

  static Future<List<Batch>> getBatches() async {
    final Directory externalStorageDir = (await getExternalStorageDirectory())!;

    final dir = Directory(externalStorageDir.path);

    return dir
        .listSync()
        .reversed
        .map((e) => Batch(
              title: path_lib.basename(e.path),
              dirPath: e.path,
              images: Directory(e.path).listSync().map((e) => e.path).toList(),
            ))
        .where((element) => element.images.isNotEmpty)
        .toList();
  }
}

import 'dart:io';

import 'package:caonalyzer/gallery/models/batch.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class GalleryReader {
  Future<List<File>> getImages(String path) async {
    final Directory externalStorageDir = (await getExternalStorageDirectory())!;

    final dir = Directory('${externalStorageDir.path}/$path');

    return dir.listSync().map((e) => File(e.path)).toList();
  }

  static Future<List<Batch>> getBatches() async {
    final Directory externalStorageDir = (await getExternalStorageDirectory())!;

    final dir = Directory(externalStorageDir.path);

    return dir
        .listSync()
        .map((e) =>
        Batch(
          title: path.basename(e.path),
          dirPath: e.path,
          images: Directory(e.path).listSync().map((e) => e.path).toList(),
        ))
        .where((element) => element.images.isNotEmpty)
        .toList();
  }
}

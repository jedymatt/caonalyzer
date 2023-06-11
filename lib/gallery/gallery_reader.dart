import 'dart:io';

import 'package:path_provider/path_provider.dart';

class GalleryReader {
  Future<List<File>> getImages(String path) async {
    final Directory externalStorageDir = (await getExternalStorageDirectory())!;

    final dir = Directory('${externalStorageDir.path}/$path');

    return dir.listSync().map((e) => File(e.path)).toList();
  }
}
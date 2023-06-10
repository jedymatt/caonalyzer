import 'dart:io';


abstract class Writer {

  void writeImages(List<String> source, String destination);
  void createBatchDirectory(String path);
}

class GalleryWriter implements Writer {
  static GalleryWriter? _instance;

  static GalleryWriter get instance => _instance ??= GalleryWriter();

  @override
  void createBatchDirectory(String path) {
    Directory(path).createSync();
  }

  @override
  void writeImages(List<String> source, String destination) {
    for (var path in source) {
      File(path).copySync(destination);
    }
  }
}

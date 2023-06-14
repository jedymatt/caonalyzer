import 'dart:io';

import 'package:caonalyzer/gallery/models/image_metadata.dart';

class MetadataWriter {
  static void create(String imagePath, ImageMetadata metadata) {
    // create metadata file in imagePath like this:
    // /path/to/image.jpg -> /path/to/image.jpg.metadata.json
    final metadataFile = File('$imagePath.metadata.json');
    metadataFile.writeAsStringSync(metadata.toJson());
  }

  static void delete(String imagePath) {
    // delete metadata file in imagePath like this:
    // /path/to/image.jpg -> /path/to/image.jpg.metadata.json
    final metadataFile = File('$imagePath.metadata.json');
    metadataFile.deleteSync();
  }
}

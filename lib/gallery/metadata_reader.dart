import 'dart:io';

import 'package:caonalyzer/gallery/models/image_metadata.dart';

class MetadataReader {
  static ImageMetadata? read(String imagePath) {
    // read metadata file in imagePath like this:
    // /path/to/image.jpg -> /path/to/image.jpg.metadata.json
    final metadataFile = File('$imagePath.metadata.json');

    if (!metadataFile.existsSync()) return null;

    final jsonString = metadataFile.readAsStringSync();

    return ImageMetadata.fromJson(jsonString);
  }

  static bool exists(String imagePath) {
    return File('$imagePath.metadata.json').existsSync();
  }
}

import 'package:caonalyzer/app/data/models/models.dart';

class Image {
  final String path;
  final List<DetectedObject>? detectedObjects;
  Image({
    required this.path,
    this.detectedObjects,
  });

  Image copyWith({
    String? path,
    List<DetectedObject>? detectedObjects,
    String? preview,
  }) {
    return Image(
      path: path ?? this.path,
      detectedObjects: detectedObjects ?? this.detectedObjects,
    );
  }
}


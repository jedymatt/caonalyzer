import 'dart:convert';

class ImageMetadata {
  ImageMetadata({
    required this.imagePath,
    required this.objectDetectionMode,
    required this.objectDetectionOutput,
  });

  final String imagePath;
  final String objectDetectionMode;
  final ObjectDetectionOutput objectDetectionOutput;

  String toJson() {
    return jsonEncode({
      'imagePath': imagePath,
      'objectDetectionMode': objectDetectionMode,
      'objectDetectionOutput': objectDetectionOutput.toJson(),
    });
  }

  factory ImageMetadata.fromJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return ImageMetadata(
      imagePath: json['imagePath'],
      objectDetectionMode: json['objectDetectionMode'],
      objectDetectionOutput: ObjectDetectionOutput.fromJson(json['objectDetectionOutput']),
    );
  }
}

class ObjectDetectionOutput {
  ObjectDetectionOutput({
    required this.class_,
    required this.confidence,
    required this.boxes,
  });

  final String class_;
  final double confidence;
  final List<double> boxes;

  String toJson() {
    return jsonEncode({
      'class': class_,
      'confidence': confidence,
      'boxes': boxes,
    });
  }

  factory ObjectDetectionOutput.fromJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return ObjectDetectionOutput(
      class_: json['class'],
      confidence: json['confidence'],
      boxes: json['boxes'].cast<double>(),
    );
  }
}

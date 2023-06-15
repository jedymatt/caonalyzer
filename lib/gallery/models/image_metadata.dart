import 'dart:convert';

class ImageMetadata {
  ImageMetadata({
    required this.imagePath,
    required this.objectDetectionMode,
    required this.objectDetectionOutputs,
  });

  final String imagePath;
  final String objectDetectionMode;
  final List<ObjectDetectionOutput> objectDetectionOutputs;

  String toJson() {
    return jsonEncode({
      'imagePath': imagePath,
      'objectDetectionMode': objectDetectionMode,
      'objectDetectionOutputs': objectDetectionOutputs.map((e) => e.toJson()).toList(),
    });
  }

  factory ImageMetadata.fromJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return ImageMetadata(
      imagePath: json['imagePath'],
      objectDetectionMode: json['objectDetectionMode'],
      objectDetectionOutputs: json['objectDetectionOutputs'].map<ObjectDetectionOutput>((e) => ObjectDetectionOutput.fromJson(e)).toList(),
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

  ObjectDetectionOutput toPixelBoxes(int height, int width) {
    return ObjectDetectionOutput(
      class_: class_,
      confidence: confidence,
      boxes: [
        boxes[0] * width,
        boxes[1] * height,
        boxes[2] * width,
        boxes[3] * height,
      ],
    );
  }
}

import 'dart:convert';

class DetectedObject {
  final String label;
  final double confidence;
  final List<double> boundingBox;
  DetectedObject({
    required this.label,
    required this.confidence,
    required this.boundingBox,
  });

  List<double> absoluteBoundingBox(double height, double width) {
    return [
      boundingBox[0] * width,
      boundingBox[1] * height,
      boundingBox[2] * width,
      boundingBox[3] * height,
    ];
  }

  String get displayLabel => '$label ${(confidence * 100).toStringAsFixed(2)}%';

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'confidence': confidence,
      'boundingBox': boundingBox,
    };
  }

  factory DetectedObject.fromMap(Map<String, dynamic> map) {
    return DetectedObject(
      label: map['label'] ?? '',
      confidence: map['confidence']?.toDouble() ?? 0.0,
      boundingBox: List<double>.from(map['boundingBox']),
    );
  }

  String toJson() => json.encode(toMap());

  factory DetectedObject.fromJson(String source) =>
      DetectedObject.fromMap(json.decode(source));

  @override
  String toString() =>
      'DetectedObject(label: $label, confidence: $confidence, boundingBox: $boundingBox)';
}

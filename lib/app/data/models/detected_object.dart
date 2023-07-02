import 'dart:convert';

class DetectedObject {
  final String label;
  final double confidence;
  final List<double> box;
  DetectedObject({
    required this.label,
    required this.confidence,
    required this.box,
  });

  List<double> absoluteBox(double height, double width) {
    return [
      box[0] * width,
      box[1] * height,
      box[2] * width,
      box[3] * height,
    ];
  }

  String get displayLabel => '$label ${(confidence * 100).toStringAsFixed(2)}%';

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'confidence': confidence,
      'box': box,
    };
  }

  factory DetectedObject.fromMap(Map<String, dynamic> map) {
    return DetectedObject(
      label: map['label'] ?? '',
      confidence: map['confidence']?.toDouble() ?? 0.0,
      box: List<double>.from(map['box']),
    );
  }

  String toJson() => json.encode(toMap());

  factory DetectedObject.fromJson(String source) =>
      DetectedObject.fromMap(json.decode(source));

  @override
  String toString() =>
      'DetectedObject(label: $label, confidence: $confidence, box: $box)';
}

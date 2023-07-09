import 'bounding_box.dart';

class ObjectDetectionOutput {
  final String label;
  final double confidence;
  final BoundingBox boundingBox;

  ObjectDetectionOutput(
    this.label,
    this.confidence,
    this.boundingBox,
  );

  @override
  String toString() {
    return 'ObjectDetectionOutput{label: $label, confidence: $confidence, boundingBox: $boundingBox}';
  }
}

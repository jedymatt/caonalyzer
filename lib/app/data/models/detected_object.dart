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
}

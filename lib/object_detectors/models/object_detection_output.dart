class ObjectDetectionOutput {
  final String label;
  final double confidence;
  final double x;
  final double y;
  final double width;
  final double height;

  ObjectDetectionOutput(
      this.label, this.confidence, this.x, this.y, this.width, this.height);

  @override
  String toString() {
    return 'ObjectDetectionOutput{label: $label, confidence: $confidence, x: $x, y: $y, width: $width, height: $height}';
  }
}

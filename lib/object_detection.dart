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

enum ObjectLabel {
  moldy;

  @override
  String toString() {
    switch (this) {
      case ObjectLabel.moldy:
        return 'Moldy';
    }
  }

  static ObjectLabel from(num value) {
    switch (value) {
      case 1:
        return ObjectLabel.moldy;
      default:
        throw Exception('Unknown ObjectLabel value: $value');
    }
  }
}

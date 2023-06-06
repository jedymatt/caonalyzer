class BoundingBox {
  final double left;
  final double top;
  final double right;
  final double bottom;

  BoundingBox({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  double get width => right - left;
  double get height => bottom - top;

  BoundingBox toPixel(num imageHeight, num imageWidth) {
    if (!_isPercentage()) return this;

    return BoundingBox(
      left: left * imageWidth,
      top: top * imageHeight,
      right: right * imageWidth,
      bottom: bottom * imageHeight,
    );
  }

  factory BoundingBox.fromPixel({
    required num left,
    required num top,
    required num right,
    required num bottom,
    required num imageHeight,
    required num imageWidth,
  }) {
    return BoundingBox(
      left: left / imageWidth,
      top: top / imageHeight,
      right: right / imageWidth,
      bottom: bottom / imageHeight,
    );
  }

  bool _isPercentage() {
    return left <= 1 && top <= 1 && right <= 1 && bottom <= 1;
  }

  @override
  String toString() {
    return 'BoundingBox{left: $left, top: $top, right: $right, bottom: $bottom}';
  }
}

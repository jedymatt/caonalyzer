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

  @override
  String toString() {
    return 'BoundingBox{left: $left, top: $top, right: $right, bottom: $bottom}';
  }

  BoundingBox toAbsoluteBoundingBox(int imageHeight, int imageWidth) {
    return BoundingBox(
      left: left * imageWidth,
      top: top * imageHeight,
      right: right * imageWidth,
      bottom: bottom * imageHeight,
    );
  }
}

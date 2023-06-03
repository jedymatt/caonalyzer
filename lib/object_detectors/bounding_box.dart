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

  @override
  String toString() {
    return 'BoundingBox{left: $left, top: $top, right: $right, bottom: $bottom}';
  }
}

/// List format is LTRB
abstract class BoundingBoxUtil {
  /// returns LTRB (xyxy) list
  static List<double> toPercentList(
      {required double left,
      required double top,
      required double right,
      required double bottom,
      required int imageHeight,
      required int imageWidth}) {
    return [
      left / imageWidth,
      top / imageHeight,
      right / imageWidth,
      bottom / imageHeight,
    ];
  }
}

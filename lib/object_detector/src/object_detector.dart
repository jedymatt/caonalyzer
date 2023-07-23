import 'package:image/image.dart';

abstract class ObjectDetector<R> {
  final double confidenceThreshold = 0.6;
  final int maxResults = 15;

  Image preprocessImage(Image image);
  Future<List<R>> runInference(Image image);
  void dispose();
}

import 'package:image/image.dart';

abstract class ObjectDetector<R> {
  Image preprocessImage(Image image);
  Future<List<R>> runInference(Image image);
  void dispose();
}

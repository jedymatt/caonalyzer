import 'package:image/image.dart';

import 'object_detection_output.dart';

abstract class ObjectDetector {
  Image preprocessImage(Image image);
  Future<List<ObjectDetectionOutput>> runInference(Image image);
  void dispose();
}

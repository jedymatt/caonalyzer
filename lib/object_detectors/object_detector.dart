import 'package:image/image.dart' show Image;

import 'object_detection_output.dart';

abstract class ObjectDetector {
  Image preprocessImage(Image image);
  Future<List<ObjectDetectionOutput>> runInference(Image image);
}

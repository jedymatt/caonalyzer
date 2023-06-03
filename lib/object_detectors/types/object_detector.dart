import 'package:image/image.dart' show Image;

import 'object_detection_output.dart';

abstract class ObjectDetector {
  Image preProcessImage(Image image);
  Future<List<ObjectDetectionOutput>> runInference(Image image);
}

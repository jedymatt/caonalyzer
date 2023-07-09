import 'dart:typed_data';

import 'object_detection_output.dart';
import 'object_detector.dart';

abstract class RealtimeObjectDetector implements ObjectDetector {
  Future<List<ObjectDetectionOutput>> runInferenceOnFrame(
    List<Uint8List> bytes,
    int imageHeight,
    int imageWidth,
  );
}

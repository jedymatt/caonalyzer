import 'dart:typed_data';

import 'package:caonalyzer/object_detectors/object_detectors.dart';

abstract class RealtimeObjectDetector implements ObjectDetector {
  Future<List<ObjectDetectionOutput>> runInferenceOnFrame(
    List<Uint8List> bytes,
    int imageHeight,
    int imageWidth,
  );
}

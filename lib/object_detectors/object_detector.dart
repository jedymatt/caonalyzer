import 'dart:typed_data';

import 'package:image/image.dart' show Image;

import 'object_detection_output.dart';

abstract class ObjectDetector {
  Image preprocessImage(Image image);
  Future<List<ObjectDetectionOutput>> runInference(Image image);
  Future<List<ObjectDetectionOutput>> runInferenceOnFrame(
    List<Uint8List> bytes,
    int imageHeight,
    int imageWidth,
  );
  void dispose();
}

import 'dart:typed_data';

import 'package:caonalyzer/object_detectors/object_detectors.dart';
import 'package:caonalyzer/services/pytorch_object_detector.dart';
import 'package:image/image.dart';

class RealtimePytorchObjectDetector implements ObjectDetector {
  final PytorchObjectDetector objectDetector = PytorchObjectDetector();

  Future<List<ObjectDetectionOutput>> runInferenceOnFrame(
    List<Uint8List> bytes,
    int imageHeight,
    int imageWidth,
  ) async {
    final model = await objectDetector.getModel();

    final results = await model.yoloOnFrame(
      bytesList: bytes,
      imageHeight: imageHeight,
      imageWidth: imageWidth,
    );

    return results.map((e) {
      final label = e['tag'];
      final confidence = e['box'][4]; // this is api bug
      final rect = BoundingBox(
        left: e['box'][0],
        top: e['box'][1],
        right: e['box'][2],
        bottom: e['box'][3],
      );

      return ObjectDetectionOutput(
        label,
        confidence,
        rect,
      );
    }).toList();
  }

  @override
  Image preprocessImage(Image image) {
    return objectDetector.preprocessImage(image);
  }

  @override
  Future<List<ObjectDetectionOutput>> runInference(Image image) {
    return objectDetector.runInference(image);
  }
}

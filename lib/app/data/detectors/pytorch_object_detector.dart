import 'dart:developer';

import 'package:caonalyzer/object_detector/object_detector.dart';
import 'package:image/image.dart'
    show Image, Interpolation, copyResize, encodeJpg;
import 'package:pytorch_lite/pytorch_lite.dart';

class PytorchObjectDetector extends ObjectDetector {
  ModelObjectDetection? _model;

  @override
  Image preprocessImage(Image image) {
    if (image.width <= 640 || image.height <= 640) {
      return image;
    }

    if (image.width > image.height) {
      image = copyResize(
        image,
        width: 640,
        interpolation: Interpolation.linear,
      );
    } else {
      image = copyResize(
        image,
        height: 640,
        interpolation: Interpolation.linear,
      );
    }

    return image;
  }

  @override
  Future<List<ObjectDetectionOutput>> runInference(Image image) async {
    final model = await getModel();

    final results = await model.getImagePredictionList(
      encodeJpg(image),
      boxesLimit: 25,
    );

    log(results.toString());

    return results.map((e) {
      final label = e!.className!;
      final confidence = e.score;
      final rect = BoundingBox.fromPercent(
        left: e.rect.left,
        top: e.rect.top,
        right: e.rect.right,
        bottom: e.rect.bottom,
      );

      return ObjectDetectionOutput(
        label,
        confidence,
        rect,
      );
    }).toList();
  }

  Future<ModelObjectDetection> getModel() async {
    _model ??= await PytorchLite.loadObjectDetectionModel(
      'assets/yolov8n.torchscript.pt',
      1,
      640,
      640,
      labelPath: 'assets/labels.txt',
      objectDetectionModelType: ObjectDetectionModelType.yolov8,
    );

    return _model!;
  }
}

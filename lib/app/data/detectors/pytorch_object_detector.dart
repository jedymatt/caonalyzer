import 'dart:developer';

import 'package:caonalyzer/app/data/models/models.dart';
import 'package:caonalyzer/app/data/utils/bounding_box_util.dart';
import 'package:caonalyzer/object_detector/object_detector.dart';
import 'package:image/image.dart'
    show Image, Interpolation, copyResize, encodeJpg;
import 'package:flutter_vision/flutter_vision.dart';

class PytorchObjectDetector extends ObjectDetector<DetectedObject> {
  FlutterVision? _model;

  @override
  Image preprocessImage(Image image) {
    if (image.width <= 640 && image.height <= 640) {
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
  Future<List<DetectedObject>> runInference(Image image) async {
    final model = await getModel();

    final results = await model.yoloOnImage(
      bytesList: encodeJpg(image),
      imageHeight: image.height,
      imageWidth: image.width,
    );

    log(results.toString());

    return results
        .map((result) => DetectedObject(
              label: result['tag'],
              // This is an api bug which returns confidence
              // and doesn't make sense
              confidence: result['box'][4],
              box: BoundingBoxUtil.toPercentList(
                left: result['box'][0],
                top: result['box'][1],
                right: result['box'][2],
                bottom: result['box'][3],
                imageHeight: image.height,
                imageWidth: image.width,
              ),
            ))
        .toList();
  }

  Future<FlutterVision> getModel() async {
    if (_model == null) {
      _model = FlutterVision();

      await _model!.loadYoloModel(
        modelPath: 'assets/yolov8n.tflite',
        labels: 'assets/labels.txt',
        modelVersion: 'yolov8',
        numThreads: 1,
        useGpu: false,
      );
    }

    return _model!;
  }

  @override
  void dispose() {
    _model?.closeYoloModel();
  }
}

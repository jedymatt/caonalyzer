import 'dart:convert';
import 'dart:developer';

import 'package:caonalyzer/object_detectors/object_detectors.dart';
import 'package:image/image.dart'
    show Image, Interpolation, copyResize, encodeBmp;
import 'package:flutter_vision/flutter_vision.dart';

class PytorchObjectDetector implements ObjectDetector {
  FlutterVision? _model;

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

    final results = await model.yoloOnImage(
      bytesList: encodeBmp(image),
      imageHeight: image.height,
      imageWidth: image.width,
    );

    log(results[0].toString());

    return results.map((e) {
      final label = e['tag'];
      final confidence = e['box'][4];
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
}

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:caonalyzer/app/data/configs/object_detector_config.dart';
import 'package:caonalyzer/globals.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:http/http.dart' as http;

import 'package:caonalyzer/object_detector/object_detector.dart';
import 'package:image/image.dart'
    show ChannelOrder, Image, Interpolation, copyResize;

class TfServingObjectDetector implements ObjectDetector {
  @override
  Image preprocessImage(Image image) {
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
    final reshaped = image
        .getBytes(order: ChannelOrder.rgb)
        .reshape([1, image.height, image.width, 3]);

    http.Response response = await requestTfServingPrediction(reshaped);

    if (response.statusCode != HttpStatus.ok) {
      log(jsonDecode(response.body)['message']);

      throw Exception(
        'Error running inference HTTP request. See logs for details.',
      );
    }

    final output = ObjectDetectionResponse.fromJson(response.body);

    return output.toObjectDetectionOutputs(
      image.height,
      image.width,
    );
  }

  Future<http.Response> requestTfServingPrediction(
    List<dynamic> reshaped,
  ) async {
    final uri = Uri.parse(ObjectDetectorConfig.serverUrl);

    final response = await http.post(
      uri,
      headers: {
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'inputs': {'input_tensor': reshaped}
      }),
    );

    return response;
  }
}

class ObjectDetectionResponse {
  final int numDetections;
  final List<List<double>> detectionBoxes;
  final List<int> detectionClasses;
  final List<double> detectionScores;

  ObjectDetectionResponse({
    required this.numDetections,
    required this.detectionBoxes,
    required this.detectionClasses,
    required this.detectionScores,
  });

  factory ObjectDetectionResponse.fromJson(String json) {
    final mappedJson = jsonDecode(json) as Map<String, dynamic>;
    final outputs = mappedJson['outputs'] as Map<String, dynamic>;
    final numDetections = (outputs['num_detections'][0] as double).toInt();

    return ObjectDetectionResponse(
      numDetections: numDetections,
      detectionBoxes: (outputs['detection_boxes'][0] as List)
          .map<List<double>>((e) => e.cast<double>())
          .toList()
          .sublist(0, numDetections),
      detectionClasses: (outputs['detection_classes'][0] as List)
          .map<int>((e) => e.toInt())
          .toList()
          .sublist(0, numDetections),
      detectionScores: (outputs['detection_scores'][0] as List)
          .cast<double>()
          .sublist(0, numDetections),
    );
  }

  List<ObjectDetectionOutput> toObjectDetectionOutputs(
      int imageHeight, int imageWidth) {
    return List.generate(
      numDetections,
      (index) => ObjectDetectionOutput(
        Globals.labels[detectionClasses[index] - 1],
        detectionScores[index],
        BoundingBox.fromPercent(
          left: detectionBoxes[index][1],
          top: detectionBoxes[index][0],
          right: detectionBoxes[index][3],
          bottom: detectionBoxes[index][2],
        ),
      ),
    );
  }
}

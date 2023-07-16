import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:caonalyzer/app/data/configs/object_detector_config.dart';
import 'package:caonalyzer/app/data/models/models.dart';
import 'package:caonalyzer/globals.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:http/http.dart' as http;

import 'package:caonalyzer/object_detector/object_detector.dart';
import 'package:image/image.dart'
    show ChannelOrder, Image, Interpolation, copyResize;

class TfServingObjectDetector extends ObjectDetector<DetectedObject> {
  final _client = http.Client();

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
    final reshaped = image
        .getBytes(order: ChannelOrder.rgb)
        .reshape([1, image.height, image.width, 3]);

    final uri = Uri.parse(ObjectDetectorConfig.serverUrl);

    http.Response response;

    try {
      response = await requestTfServingPrediction(uri, reshaped);
    } on http.ClientException catch (_) {
      throw ObjectDetectorInferenceException(
        'Error connecting to inference server.',
      );
    }

    if (response.statusCode != HttpStatus.ok) {
      log(jsonDecode(response.body)['message']);

      throw ObjectDetectorInferenceException(
        'Error running inference HTTP request. See logs for details.',
      );
    }

    final output = ObjectDetectionResponse.fromJson(response.body);

    return output.mapToDetectedObjects(
      image.height,
      image.width,
    );
  }

  Future<http.Response> requestTfServingPrediction(
    Uri uri,
    List<dynamic> reshaped,
  ) async {
    final response = await _client.post(
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

  @override
  void dispose() {
    _client.close();
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

  List<DetectedObject> mapToDetectedObjects(int imageHeight, int imageWidth) {
    return List.generate(
      numDetections,
      (index) {
        return DetectedObject(
          label: Globals.labels[detectionClasses[index] - 1],
          confidence: detectionScores[index],
          box: [
            detectionBoxes[index][1],
            detectionBoxes[index][0],
            detectionBoxes[index][3],
            detectionBoxes[index][2],
          ],
        );
      },
    );
  }
}

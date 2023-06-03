import 'dart:convert';

import 'package:caonalyzer/globals.dart';
import 'package:caonalyzer/object_detectors/object_detectors.dart';

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
        labels[detectionClasses[index] - 1],
        detectionScores[index],
        BoundingBox(
          left: detectionBoxes[index][1],
          top: detectionBoxes[index][0],
          right: detectionBoxes[index][3],
          bottom: detectionBoxes[index][2],
        ).toAbsoluteBoundingBox(imageHeight, imageWidth),
      ),
    );
  }
}

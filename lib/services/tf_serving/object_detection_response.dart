import 'package:caonalyzer/globals.dart';
import 'package:caonalyzer/object_detectors/types/bounding_box.dart';
import 'package:caonalyzer/object_detectors/types/object_detection_output.dart';

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

  factory ObjectDetectionResponse.fromMap(Map<String, dynamic> map) {
    final outputs = map['outputs'] as Map<String, dynamic>;
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

  List<ObjectDetectionOutput> toObjectDetectionOutputs() {
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
        ),
      ),
    );
  }
}

class ObjectDetectionOutput {
  final int numDetections;
  final List<List<double>> detectionBoxes;
  final List<int> detectionClasses;
  final List<double> detectionScores;

  ObjectDetectionOutput({
    required this.numDetections,
    required this.detectionBoxes,
    required this.detectionClasses,
    required this.detectionScores,
  });

  factory ObjectDetectionOutput.fromMap(Map<String, dynamic> map) {
    final numDetections = (map['num_detections'][0] as double).toInt();

    return ObjectDetectionOutput(
      numDetections: numDetections,
      detectionBoxes: (map['detection_boxes'][0] as List)
          .map<List<double>>((e) => e.cast<double>())
          .toList()
          .sublist(0, numDetections),
      detectionClasses: (map['detection_classes'][0] as List)
          .map<int>((e) => e.toInt())
          .toList()
          .sublist(0, numDetections),
      detectionScores: (map['detection_scores'][0] as List)
          .cast<double>()
          .sublist(0, numDetections),
    );
  }

  factory ObjectDetectionOutput.empty() {
    return ObjectDetectionOutput(
      numDetections: 0,
      detectionBoxes: [],
      detectionClasses: [],
      detectionScores: [],
    );
  }
}

class ObjectDetectorInferenceException implements Exception {
  final String message;

  ObjectDetectorInferenceException(this.message);

  @override
  String toString() {
    return 'DetectorException: $message';
  }
}

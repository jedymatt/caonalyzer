class ObjectDetectorException implements Exception {
  final String message;

  ObjectDetectorException(this.message);

  @override
  String toString() {
    return 'DetectorException: $message';
  }
}

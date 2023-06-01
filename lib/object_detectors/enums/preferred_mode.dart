import '../object_detector.dart';
import '../online_object_detector.dart';

enum PreferredMode {
  online,
  offline;

  ObjectDetector get objectDetector {
    switch (this) {
      case PreferredMode.online:
        return OnlineObjectDetector();
      case PreferredMode.offline:
        throw UnimplementedError('Offline mode is not implemented yet');
      default:
        return OnlineObjectDetector();
    }
  }

  // forceOffline
  ObjectDetector get offlineObjectDetector {
    throw UnimplementedError('Offline mode is not implemented yet');
  }
}

import 'package:caonalyzer/object_detectors/object_detector.dart';
import 'package:caonalyzer/object_detectors/online_object_detector.dart';

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
}

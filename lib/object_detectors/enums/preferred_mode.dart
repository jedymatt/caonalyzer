import 'package:caonalyzer/services/tf_serving/tf_serving_object_detector.dart';

import '../types/object_detector.dart';

enum PreferredMode {
  online,
  offline;

  ObjectDetector get objectDetector {
    switch (this) {
      case PreferredMode.online:
        return TfServingObjectDetector();
      case PreferredMode.offline:
        throw UnimplementedError('Offline mode is not implemented yet');
    }
  }
}

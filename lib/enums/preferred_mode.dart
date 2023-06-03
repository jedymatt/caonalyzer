import 'package:caonalyzer/services/tf_serving/tf_serving_object_detector.dart';

import 'package:caonalyzer/object_detectors/types/types.dart';

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

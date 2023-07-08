import 'package:caonalyzer/app/data/detectors/detectors.dart';

import 'package:caonalyzer/object_detectors/object_detectors.dart';

enum PreferredMode {
  online,
  offline;

  ObjectDetector get objectDetector {
    switch (this) {
      case PreferredMode.online:
        return TfServingObjectDetector();
      case PreferredMode.offline:
        return PytorchObjectDetector();
    }
  }

  RealtimeObjectDetector get realtimeObjectDetector {
    return RealtimePytorchObjectDetector();
  }
}

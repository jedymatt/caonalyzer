import 'package:caonalyzer/app/data/detectors/detectors.dart';
import 'package:caonalyzer/locator.dart';

import 'package:caonalyzer/object_detector/object_detector.dart';

enum PreferredMode {
  online,
  offline;

  ObjectDetector get objectDetector {
    switch (this) {
      case PreferredMode.online:
        return locator.get<TfServingObjectDetector>();
      case PreferredMode.offline:
        return locator.get<PytorchObjectDetector>();
    }
  }

  RealtimeObjectDetector get realtimeObjectDetector {
    return RealtimePytorchObjectDetector();
  }
}

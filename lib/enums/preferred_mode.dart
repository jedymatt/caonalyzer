import 'package:caonalyzer/app/data/services/pytorch_object_detector.dart';
import 'package:caonalyzer/app/data/services/realtime_pytorch_object_detector.dart';
import 'package:caonalyzer/app/data/services/tf_serving_object_detector.dart';

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

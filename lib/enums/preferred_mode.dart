import 'package:caonalyzer/app/data/detectors/detectors.dart';
import 'package:caonalyzer/object_detector/object_detector.dart';

enum PreferredMode {
  online,
  offline;

  ObjectDetector get makeObjectDetector {
    switch (this) {
      case PreferredMode.online:
        return TfServingObjectDetector();
      case PreferredMode.offline:
        return PytorchObjectDetector();
    }
  }
}

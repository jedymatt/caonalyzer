import 'package:caonalyzer/app/data/detectors/detectors.dart';
import 'package:caonalyzer/app/data/models/models.dart';
import 'package:caonalyzer/object_detector/object_detector.dart';

enum PreferredMode {
  offline;

  ObjectDetector<DetectedObject> get makeObjectDetector {
    switch (this) {
      case PreferredMode.offline:
        return PytorchObjectDetector();
    }
  }
}

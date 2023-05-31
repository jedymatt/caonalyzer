import 'package:image/image.dart' as img;
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';

import 'package:caonalyzer/object_detectors/models/object_detection_output.dart';

abstract class ObjectDetector {
  TensorImage preProcessImage(img.Image image);

  Future<List<ObjectDetectionOutput>> runInference(TensorImage tensorImage);
}

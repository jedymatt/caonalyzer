import 'package:image/image.dart' as img;
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';

import './object_detection_output.dart';
import './ops/scale_op.dart';

abstract class ObjectDetector {
  TensorImage preProcessImage(img.Image image) {
    ImageProcessor imageProcessor = ImageProcessorBuilder()
        .add(ScaleOp(640, ResizeMethod.bilinear))
        .build();

    TensorImage tensorImage = TensorImage.fromImage(image);

    return imageProcessor.process(tensorImage);
  }

  Future<ObjectDetectionOutput> runInference(TensorImage tensorImage);
}

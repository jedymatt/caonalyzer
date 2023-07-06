import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:caonalyzer/app/data/configs/configs.dart';
import 'package:caonalyzer/app/data/models/models.dart';
import 'package:caonalyzer/app/data/services/tf_serving_object_detector.dart';
import 'package:caonalyzer/app/data/utils/image_utils.dart';
import 'package:caonalyzer/enums/preferred_mode.dart';
import 'package:caonalyzer/object_detectors/object_detectors.dart';
import 'package:meta/meta.dart';
import 'package:image/image.dart' as image_lib;

part 'detector_event.dart';
part 'detector_state.dart';

class DetectorBloc extends Bloc<DetectorEvent, DetectorState> {
  DetectorBloc() : super(DetectorInitial()) {
    on<DetectorStarted>(_onStarted);
  }

  FutureOr<void> _onStarted(
      DetectorStarted event, Emitter<DetectorState> emit) async {
    emit(DetectorInProgress());

    var image = ImageUtils.convertCameraImage(event.image)!;
    image = image_lib.copyRotate(image, 90);

    final detector = ObjectDetectorConfig.mode.value.objectDetector;

    image = detector.preprocessImage(image);

    List<ObjectDetectionOutput> detectedObjects = [];

    if (detector is TfServingObjectDetector) {
      try {
        detectedObjects = await detector.runInference(image);
      } catch (e) {
        ObjectDetectorConfig.mode.save(PreferredMode.offline);

        emit(const DetectorFailure(
          message: 'Online mode failed, switching to offline mode',
        ));
      }
    } else {
      detectedObjects = await detector.runInference(image);
    }

    emit(DetectorSuccess(
      detectedObjects: detectedObjects
          .map((e) => DetectedObject(
                label: e.label,
                confidence: e.confidence,
                box: e.boundingBox.toLTRBList(),
              ))
          .toList(),
    ));
  }

  image_lib.Image _convertCameraImage(CameraImage image) {
    int width = image.width;
    int height = image.height;
    // image_lib -> Image package from https://pub.dartlang.org/packages/image
    var img = image_lib.Image(width, height); // Create Image buffer
    const int hexFF = 0xFF000000;
    final int uvyButtonStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel!;
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final int uvIndex =
            uvPixelStride * (x / 2).floor() + uvyButtonStride * (y / 2).floor();
        final int index = y * width + x;
        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];
        // Calculate pixel color
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        // color: 0x FF  FF  FF  FF
        //           A   B   G   R
        img.data[index] = hexFF | (b << 16) | (g << 8) | r;
      }
    }

    // Rotate 90 degrees to upright
    var img1 = image_lib.copyRotate(img, 90);
    return img1;
  }
}

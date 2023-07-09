import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:caonalyzer/app/data/configs/configs.dart';
import 'package:caonalyzer/app/data/models/models.dart';
import 'package:caonalyzer/enums/preferred_mode.dart';
import 'package:caonalyzer/locator.dart';
import 'package:caonalyzer/app/data/detectors/detectors.dart';
import 'package:caonalyzer/app/data/utils/image_utils_isolate.dart';
import 'package:caonalyzer/object_detector/object_detector.dart';
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

    List<ObjectDetectionOutput> detectedObjects = [];

    final currentMode = ObjectDetectorConfig.mode.value;

    if (currentMode == PreferredMode.offline) {
      final detector = locator.get<RealtimePytorchObjectDetector>();

      detectedObjects = await detector.runInferenceOnFrame(
        event.image.planes.map((plane) => plane.bytes).toList(),
        event.image.height,
        event.image.width,
      );
    }
    if (currentMode == PreferredMode.online) {
      image_lib.Image image =
          (await ImageUtilsIsolate.convertCameraImage(event.image))!;
      image = image_lib.copyRotate(image, angle: 90);

      final detector = currentMode.objectDetector;

      image = detector.preprocessImage(image);

      try {
        detectedObjects = await detector.runInference(image);
      } catch (e) {
        ObjectDetectorConfig.mode.save(PreferredMode.offline);

        emit(const DetectorFailure(
          message: 'Online mode failed, switching to offline mode',
        ));
      }
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
}

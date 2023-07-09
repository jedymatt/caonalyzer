import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:caonalyzer/app/data/configs/configs.dart';
import 'package:caonalyzer/app/data/models/models.dart';
import 'package:caonalyzer/app/data/detectors/detectors.dart';
import 'package:caonalyzer/app/data/utils/image_utils_isolate.dart';
import 'package:caonalyzer/enums/preferred_mode.dart';
import 'package:caonalyzer/object_detector/object_detector.dart';
import 'package:meta/meta.dart';

part 'detector_event.dart';
part 'detector_state.dart';

class DetectorBloc extends Bloc<DetectorEvent, DetectorState> {
  DetectorBloc() : super(DetectorInitial()) {
    on<DetectorStarted>(_onStarted);
  }

  FutureOr<void> _onStarted(
      DetectorStarted event, Emitter<DetectorState> emit) async {
    emit(DetectorInProgress());

    var image = (await ImageUtilsIsolate.convertCameraImage(event.image))!;

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
}

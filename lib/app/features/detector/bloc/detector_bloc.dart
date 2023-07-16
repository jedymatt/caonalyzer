import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:caonalyzer/app/data/configs/configs.dart';
import 'package:caonalyzer/app/data/models/models.dart';
import 'package:caonalyzer/app/data/utils/image_utils_isolate.dart';
import 'package:caonalyzer/object_detector/object_detector.dart';
import 'package:meta/meta.dart';

part 'detector_event.dart';
part 'detector_state.dart';

class DetectorBloc extends Bloc<DetectorEvent, DetectorState> {
  final ObjectDetector _detector =
      ObjectDetectorConfig.mode.value.makeObjectDetector;

  DetectorBloc() : super(DetectorInitial()) {
    ImageUtilsIsolate.init();

    on<DetectorStarted>(_onStarted);
  }

  FutureOr<void> _onStarted(
      DetectorStarted event, Emitter<DetectorState> emit) async {
    if (state is DetectorInProgress || state is DetectorFailure) return;

    emit(DetectorInProgress());

    var image = (await ImageUtilsIsolate.convertCameraImage(event.image))!;

    image = _detector.preprocessImage(image);

    List<ObjectDetectionOutput> detectedObjects = [];

    try {
      detectedObjects = await _detector.runInference(image);
    } on ObjectDetectorInferenceException catch (e) {
      emit(DetectorFailure(message: e.message));
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

  @override
  Future<void> close() {
    _detector.dispose();
    ImageUtilsIsolate.dispose();
    return super.close();
  }
}

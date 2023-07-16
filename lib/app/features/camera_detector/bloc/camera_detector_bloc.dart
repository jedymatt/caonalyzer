import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:caonalyzer/app/data/configs/configs.dart';
import 'package:caonalyzer/app/data/models/models.dart';
import 'package:caonalyzer/app/data/utils/image_utils_isolate.dart';
import 'package:caonalyzer/object_detector/object_detector.dart';
import 'package:meta/meta.dart';

part 'camera_detector_event.dart';
part 'camera_detector_state.dart';

class CameraDetectorBloc
    extends Bloc<CameraDetectorEvent, CameraDetectorState> {
  final ObjectDetector<DetectedObject> _detector =
      ObjectDetectorConfig.mode.value.makeObjectDetector;

  CameraDetectorBloc() : super(CameraDetectorInitial()) {
    ImageUtilsIsolate.init();

    on<CameraDetectorStarted>(_onStarted);
  }

  FutureOr<void> _onStarted(
      CameraDetectorStarted event, Emitter<CameraDetectorState> emit) async {
    if (state is CameraDetectorInProgress || state is CameraDetectorFailure) {
      return;
    }
    emit(CameraDetectorInProgress());

    var image = (await ImageUtilsIsolate.convertCameraImage(event.image))!;

    image = _detector.preprocessImage(image);

    List<DetectedObject> detectedObjects = [];

    try {
      detectedObjects = await _detector.runInference(image);
    } on ObjectDetectorInferenceException catch (e) {
      emit(CameraDetectorFailure(message: e.message));
    }

    emit(CameraDetectorSuccess(
      detectedObjects: detectedObjects,
    ));
  }

  @override
  Future<void> close() {
    _detector.dispose();
    ImageUtilsIsolate.dispose();
    return super.close();
  }
}

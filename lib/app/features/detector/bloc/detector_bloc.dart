import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:caonalyzer/app/data/models/models.dart';
import 'package:caonalyzer/app/data/services/pytorch_object_detector.dart';
import 'package:caonalyzer/app/data/utils/image_utils.dart';
import 'package:caonalyzer/object_detectors/object_detector.dart';
import 'package:meta/meta.dart';
import 'package:image/image.dart' as image_lib;

part 'detector_event.dart';
part 'detector_state.dart';

class DetectorBloc extends Bloc<DetectorEvent, DetectorState> {
  final ObjectDetector _detector = PytorchObjectDetector();

  DetectorBloc() : super(DetectorInitial()) {
    on<DetectorStarted>(_onStarted);
  }

  FutureOr<void> _onStarted(
      DetectorStarted event, Emitter<DetectorState> emit) async {
    emit(DetectorInProgress());

    var image = ImageUtils.convertCameraImage(event.image)!;
    image = image_lib.copyRotate(image, 90);
    image = _detector.preprocessImage(image);

    final detectedObjects = await _detector.runInference(image);

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

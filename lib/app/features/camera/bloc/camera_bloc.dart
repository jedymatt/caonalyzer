import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:caonalyzer/app/data/models/models.dart';
import 'package:caonalyzer/app/data/services/realtime_pytorch_object_detector.dart';
import 'package:caonalyzer/globals.dart';
import 'package:meta/meta.dart';

part 'camera_event.dart';

part 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  late CameraController _cameraController;
  final RealtimePytorchObjectDetector _detector =
      RealtimePytorchObjectDetector();
  final CameraCaptureMode _mode;
  int _emptyPreviousCount = 0;

  CameraBloc({required CameraCaptureMode mode})
      : _mode = mode,
        super(CameraInitial(mode: mode)) {
    on<CameraStarted>(_onStarted);
    on<CameraStopped>(_onStopped);
    on<CameraCaptured>(_onCaptured);
    on<CameraDetectionToggled>(_onDetectionToggled);
    on<_CameraImageDetected>(_onCameraImageDetected);
    on<CameraDetectionPauseToggled>(_onDetectionPauseToggled);
  }

  CameraController get controller => _cameraController;

  FutureOr<void> _onCameraImageDetected(
      _CameraImageDetected event, Emitter<CameraState> emit) async {
    final state_ = state;

    if (state_ is! CameraDetectionReady) return;

    final detectedObjects = await _detector.runInferenceOnFrame(
        event.image.planes.map((plane) => plane.bytes).toList(),
        event.image.height,
        event.image.width);

    if (detectedObjects.isNotEmpty) {
      emit(state_.copyWith(
        detectedObjects: detectedObjects
            .map((e) => DetectedObject(
                  label: e.label,
                  confidence: e.confidence,
                  boundingBox: e.boundingBox.toLTRBList(),
                ))
            .toList(),
        image: event.image,
      ));
      _emptyPreviousCount = 0;
    } else {
      _emptyPreviousCount++;
    }

    if (detectedObjects.isEmpty && _emptyPreviousCount >= 20) {
      emit(state_.copyWith(
        detectedObjects: [],
        image: event.image,
      ));
    }
  }

  FutureOr<void> _onStarted(
      CameraStarted event, Emitter<CameraState> emit) async {
    if (state is! CameraInitial) return;
    try {
      _cameraController = CameraController(
        Globals.cameras.first,
        // set to low resolution for object detection to work
        ResolutionPreset.low,
        enableAudio: false,
      );

      await _cameraController.initialize();

      emit(CameraReady(mode: event.mode));
    } on CameraException catch (e) {
      _cameraController.dispose();
      emit(CameraFailure(message: e.description!));
    } catch (e) {
      emit(CameraFailure(message: e.toString()));
    }
  }

  FutureOr<void> _onStopped(CameraStopped event, Emitter<CameraState> emit) {
    _cameraController.dispose();
    if (state is! CameraReady) return null;

    final state_ = state as CameraReady;
    emit(CameraInitial(mode: state_.mode));
  }

  FutureOr<void> _onCaptured(
      CameraCaptured event, Emitter<CameraState> emit) async {
    if (state is! CameraReady) return;

    final state_ = state as CameraReady;

    try {
      emit(CameraCaptureInProgress());

      final image = await _cameraController.takePicture();

      emit(CameraCaptureSuccess(path: image.path, mode: state_.mode));
      emit(CameraReady(mode: state_.mode));
    } on CameraException catch (e) {
      emit(CameraCaptureFailure(message: e.description!));
    }
  }

  FutureOr<void> _onDetectionToggled(
      CameraDetectionToggled event, Emitter<CameraState> emit) async {
    final state_ = state;

    if (state_ is! CameraReady && state_ is! CameraDetectionReady) return;

    emit(CameraSwitchDisplayModeInProgress());

    if (state_ is CameraReady) {
      await _cameraController.startImageStream(
        (image) => add(_CameraImageDetected(image)),
      );

      emit(CameraDetectionReady());
    }

    if (state_ is CameraDetectionReady) {
      await _cameraController.stopImageStream();
      emit(CameraReady(mode: _mode));
    }
  }

  @override
  Future<void> close() async {
    if (_cameraController.value.isStreamingImages) {
      await _cameraController.stopImageStream();
    }
    await _cameraController.dispose();

    return super.close();
  }

  FutureOr<void> _onDetectionPauseToggled(
      CameraDetectionPauseToggled event, Emitter<CameraState> emit) async {
    final state_ = state;

    if (state_ is! CameraDetectionReady) return;

    if (state_.paused) {
      await _cameraController.resumePreview();
    } else {
      await _cameraController.pausePreview();
    }
    emit(state_.copyWith(paused: !state_.paused));
  }
}

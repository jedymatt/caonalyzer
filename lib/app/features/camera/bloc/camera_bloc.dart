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

  CameraBloc({required CameraCaptureMode mode})
      : super(CameraInitial(mode: mode)) {
    on<CameraStarted>(_onStarted);
    on<CameraStopped>(_onStopped);
    on<CameraCaptured>(_onCaptured);
    on<CameraDetectionToggled>(_onDetectionToggled);
    on<_CameraImageDetected>(_onCameraImageDetected);
    on<CameraDetectionPauseToggled>(_onDetectionPauseToggled);
  }

  FutureOr<void> _onCameraImageDetected(
      _CameraImageDetected event, Emitter<CameraState> emit) async {
    final state_ = state;

    if (state_ is! CameraReady) return;

    final detectedObjects = (await _detector.runInferenceOnFrame(
            event.image.planes.map((plane) => plane.bytes).toList(),
            event.image.height,
            event.image.width))
        .map((e) => DetectedObject(
              label: e.label,
              confidence: e.confidence,
              boundingBox: e.boundingBox.toLTRBList(),
            ))
        .toList();

    if (detectedObjects.isNotEmpty) {
      print(detectedObjects.first.boundingBox);
    }

    emit(state_.copyWith(
      detectionEnabled: true,
      detectedObjects: detectedObjects,
    ));
  }

  FutureOr<void> _onStarted(
      CameraStarted event, Emitter<CameraState> emit) async {
    if (state is! CameraInitial) return;
    try {
      _cameraController = CameraController(
        Globals.cameras.first,
        ResolutionPreset.medium,
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

    if (state_.detectionEnabled) {
      return;
    }

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

    if (state_ is! CameraReady) return null;

    if (state_.detectionEnabled) {
      await _cameraController.stopImageStream();
      emit(state_.copyWith(detectionEnabled: false));
    } else {
      if (_cameraController.value.isPreviewPaused) {
        await _cameraController.resumePreview();
      }
      await _cameraController.startImageStream(_processImageStream);
      emit(state_.copyWith(detectionEnabled: true));
    }
  }

  _processImageStream(image) {
    add(_CameraImageDetected(image));
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

    if (state_ is! CameraReady) return;

    if (!state_.detectionEnabled) return;

    if (state_.detectionPaused) {
      await _cameraController.resumePreview();
    } else {
      await _cameraController.pausePreview();
    }
    emit(state_.copyWith(detectionPaused: !state_.detectionPaused));
  }
}

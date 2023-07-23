import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:caonalyzer/globals.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

part 'camera_event.dart';
part 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  CameraController? _cameraController;

  CameraBloc({required CameraCaptureMode mode})
      : super(CameraInitial(mode: mode)) {
    on<CameraStarted>(_onStarted);
    on<CameraStopped>(_onStopped);
    on<CameraCaptured>(_onCaptured);
    on<CameraDetectionPauseToggled>(_onDetectionPauseToggled);
    on<CameraDisplayModeChanged>(_onDisplayModeChanged);
    on<CameraFlashModeChanged>(_onFlashModeChanged);
  }

  CameraController get controller => _cameraController!;

  FutureOr<void> _onStarted(
      CameraStarted event, Emitter<CameraState> emit) async {
    if (state is! CameraInitial) return;
    try {
      _cameraController = CameraController(
        Globals.cameras.first,
        // set to low resolution for object detection to work
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      emit(CameraReady(captureMode: event.mode));
    } on CameraException catch (e) {
      _cameraController!.dispose();
      emit(CameraFailure(message: e.description!));
    } catch (e) {
      emit(CameraFailure(message: e.toString()));
    }
  }

  FutureOr<void> _onStopped(
      CameraStopped event, Emitter<CameraState> emit) async {
    _cameraController!.dispose();
    if (state is! CameraReady) return null;

    final state_ = state as CameraReady;

    await _cameraController!.dispose();
    emit(CameraInitial(mode: state_.captureMode));
  }

  FutureOr<void> _onCaptured(
      CameraCaptured event, Emitter<CameraState> emit) async {
    if (state is! CameraReady) return;

    final state_ = state as CameraReady;

    try {
      emit(CameraCaptureInProgress());

      final image = await _cameraController!.takePicture();

      emit(CameraCaptureSuccess(path: image.path, mode: state_.captureMode));
      emit(state_.copyWith());
    } on CameraException catch (e) {
      emit(CameraCaptureFailure(message: e.description!));
    }
  }

  @override
  Future<void> close() async {
    if (_cameraController != null) {
      if (_cameraController!.value.isStreamingImages) {
        await _cameraController!.stopImageStream();
      }
      await _cameraController!.dispose();
    }

    return super.close();
  }

  FutureOr<void> _onDetectionPauseToggled(
      CameraDetectionPauseToggled event, Emitter<CameraState> emit) async {
    final state_ = state;

    if (state_ is! CameraReady) return;

    if (state_.displayMode != CameraDisplayMode.analysis) return;

    // resume/pause preview
    if (state_.displayPaused) {
      await _cameraController!.resumePreview();
    } else {
      await _cameraController!.pausePreview();
    }

    emit(state_.copyWith(displayPaused: !state_.displayPaused));
  }

  FutureOr<void> _onDisplayModeChanged(
      CameraDisplayModeChanged event, Emitter<CameraState> emit) async {
    final state_ = state;

    if (state_ is! CameraReady) return;

    if (event.displayMode == state_.displayMode) return;

    if (event.displayMode == CameraDisplayMode.photo) {
      await _cameraController!.resumePreview();
    }

    emit(state_.copyWith(
      displayMode: event.displayMode,
      displayPaused: _cameraController!.value.isPreviewPaused,
    ));
  }

  FutureOr<void> _onFlashModeChanged(
      CameraFlashModeChanged event, Emitter<CameraState> emit) async {
    final state_ = state;

    if (state_ is! CameraReady) return;

    if (event.flashMode == state_.flashMode) return;

    switch (event.flashMode) {
      case CameraFlashMode.auto:
        await _cameraController!.setFlashMode(FlashMode.auto);
        break;
      case CameraFlashMode.on:
        await _cameraController!.setFlashMode(FlashMode.always);
        break;
      case CameraFlashMode.off:
        await _cameraController!.setFlashMode(FlashMode.off);
        break;
      case CameraFlashMode.torch:
        await _cameraController!.setFlashMode(FlashMode.torch);
        break;
      default:
        await _cameraController!.setFlashMode(FlashMode.auto);
    }

    emit(state_.copyWith(flashMode: event.flashMode));
  }
}

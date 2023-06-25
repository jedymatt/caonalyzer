import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:caonalyzer/globals.dart';
import 'package:meta/meta.dart';

part 'camera_event.dart';
part 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  late CameraController _cameraController;

  CameraBloc({required CameraCaptureMode mode})
      : super(CameraInitial(mode: mode)) {
    on<CameraStarted>(_onStarted);
    on<CameraStopped>(_onStopped);
    on<CameraCaptured>(_onCaptured);
  }

  CameraController get controller => _cameraController;

  FutureOr<void> _onStarted(
      CameraStarted event, Emitter<CameraState> emit) async {
    if (state is! CameraInitial) return;
    try {
      _cameraController = CameraController(
        Globals.cameras.first,
        ResolutionPreset.low,
        enableAudio: false,
      );

      await _cameraController.initialize();

      emit(CameraReady(mode: event.mode, controller: _cameraController));
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
      await _cameraController.setFlashMode(FlashMode.off);
      await _cameraController.setFlashMode(FlashMode.auto);
      emit(CameraCaptureSuccess(path: image.path, mode: state_.mode));
      emit(CameraReady(mode: state_.mode, controller: _cameraController));
    } on CameraException catch (e) {
      emit(CameraCaptureFailure(message: e.description!));
    }
  }

  @override
  Future<void> close() {
    _cameraController.dispose();
    return super.close();
  }
}

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:caonalyzer/gallery/gallery_writer.dart';
import 'package:caonalyzer/globals.dart';
import 'package:meta/meta.dart';

part 'camera_event.dart';
part 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  late CameraController _cameraController;

  CameraBloc() : super(CameraInitial()) {
    on<CameraStarted>(_onStarted);
    on<CameraStopped>(_onStopped);
    on<CameraCaptured>(_onCaptured);
  }

  CameraController get controller => _cameraController;

  FutureOr<void> _onStarted(
      CameraStarted event, Emitter<CameraState> emit) async {
    try {
      _cameraController = CameraController(
        Globals.cameras.first,
        ResolutionPreset.low,
        enableAudio: false,
      );
      await _cameraController.initialize();
      emit(CameraReady(
        mode: event.mode,
        images: const [],
      ));
    } on CameraException catch (e) {
      _cameraController.dispose();
      emit(CameraFailure(message: e.description!));
    } catch (e) {
      emit(CameraFailure(message: e.toString()));
    }
  }

  FutureOr<void> _onStopped(CameraStopped event, Emitter<CameraState> emit) {
    _cameraController.dispose();
    emit(CameraInitial());
  }

  FutureOr<void> _onCaptured(
      CameraCaptured event, Emitter<CameraState> emit) async {
    if (state is! CameraReady) return;

    final state_ = state as CameraReady;

    try {
      emit(CameraCaptureInProgress());

      if (state_.mode == CameraCaptureMode.batch) {
        final image = await _cameraController.takePicture();

        emit(state_.copyWith(
          images: List.from(state_.images)..add(image.path),
          batchPath: state_.images.isEmpty
              ? await GalleryWriter.generateBatchPath(DateTime.now())
              : state_.batchPath,
        ));
      } else {
        final image = await _cameraController.takePicture();

        emit(CameraCaptureSuccess(path: image.path));
      }
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

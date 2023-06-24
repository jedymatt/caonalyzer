part of 'camera_bloc.dart';

enum CameraCaptureMode { single, batch }

@immutable
abstract class CameraState {}

class CameraInitial extends CameraState {
  final CameraCaptureMode mode;
  CameraInitial({
    required this.mode,
  });
}

class CameraReady extends CameraState {
  final CameraCaptureMode mode;
  CameraReady({
    required this.mode,
  });
}

class CameraFailure extends CameraState {
  final String message;

  CameraFailure({required this.message});
}

class CameraCaptureInProgress extends CameraState {}

class CameraCaptureSuccess extends CameraState {
  final String path;
  final CameraCaptureMode mode;
  final String? batchPath;
  CameraCaptureSuccess({
    required this.path,
    required this.mode,
    this.batchPath,
  });
}

class CameraCaptureFailure extends CameraState {
  final String message;

  CameraCaptureFailure({required this.message});
}

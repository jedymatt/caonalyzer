part of 'camera_bloc.dart';

enum CameraCaptureMode { single, batch }

enum CameraDisplayMode { photo, analysis }

@immutable
abstract class CameraState {}

abstract class CameraActionState extends CameraState {}

class CameraInitial extends CameraState {
  final CameraCaptureMode mode;

  CameraInitial({
    required this.mode,
  });
}

class CameraReady extends CameraState {
  final CameraCaptureMode captureMode;
  final CameraDisplayMode displayMode;
  final bool displayPaused;

  CameraReady({
    required this.captureMode,
    this.displayMode = CameraDisplayMode.photo,
    this.displayPaused = false,
  });

  CameraReady copyWith({
    CameraCaptureMode? captureMode,
    CameraDisplayMode? displayMode,
    bool? displayPaused,
  }) {
    return CameraReady(
      captureMode: captureMode ?? this.captureMode,
      displayMode: displayMode ?? this.displayMode,
      displayPaused: displayPaused ?? this.displayPaused,
    );
  }
}

class CameraFailure extends CameraState {
  final String message;

  CameraFailure({required this.message});
}

class CameraCaptureInProgress extends CameraActionState {}

class CameraCaptureSuccess extends CameraActionState {
  final String path;
  final CameraCaptureMode mode;

  CameraCaptureSuccess({
    required this.path,
    required this.mode,
  });
}

class CameraCaptureFailure extends CameraActionState {
  final String message;

  CameraCaptureFailure({required this.message});
}

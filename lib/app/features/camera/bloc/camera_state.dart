part of 'camera_bloc.dart';

enum CameraCaptureMode { single, batch }

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
  final CameraCaptureMode mode;

  CameraReady({
    required this.mode,
  });

  CameraReady copyWith({
    CameraCaptureMode? mode,
  }) {
    return CameraReady(
      mode: mode ?? this.mode,
    );
  }
}

class CameraSwitchDisplayModeInProgress extends CameraState {}

class CameraDetectionReady extends CameraState {
  final bool paused;
  final CameraImage? image;

  CameraDetectionReady({
    this.paused = false,
    this.image,
  });

  CameraDetectionReady copyWith({
    bool? paused,
    CameraImage? image,
  }) {
    return CameraDetectionReady(
      paused: paused ?? this.paused,
      image: image ?? this.image,
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

class CameraDetectionImageFrame extends CameraState {
  final CameraImage image;

  CameraDetectionImageFrame(this.image);
}

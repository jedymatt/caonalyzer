part of 'camera_bloc.dart';

enum CameraCaptureMode { single, batch }

@immutable
abstract class CameraState {}

class CameraInitial extends CameraState {}

class CameraReady extends CameraState {
  final CameraCaptureMode mode;
  final List<String> images;
  final String? batchPath;

  CameraReady({
    required this.mode,
    required this.images,
    this.batchPath,
  });

  CameraReady copyWith({
    CameraCaptureMode? mode,
    List<String>? images,
    String? batchPath,
  }) {
    return CameraReady(
      mode: mode ?? this.mode,
      images: images ?? this.images,
      batchPath: batchPath ?? this.batchPath,
    );
  }
}

class CameraFailure extends CameraState {
  final String message;

  CameraFailure({required this.message});
}

class CameraCaptureInProgress extends CameraState {}

class CameraCaptureSuccess extends CameraState {
  final String path;
  CameraCaptureSuccess({required this.path});
}

class CameraCaptureFailure extends CameraState {
  final String message;

  CameraCaptureFailure({required this.message});
}

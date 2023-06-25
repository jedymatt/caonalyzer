part of 'camera_bloc.dart';

@immutable
abstract class CameraEvent {}

class CameraStarted extends CameraEvent {
  final CameraCaptureMode mode;
  CameraStarted({
    required this.mode,
  });
}

class CameraStopped extends CameraEvent {}

class CameraCaptured extends CameraEvent {}

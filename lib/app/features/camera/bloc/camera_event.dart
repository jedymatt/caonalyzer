part of 'camera_bloc.dart';

@immutable
abstract class CameraEvent {}

class CameraStarted extends CameraEvent {}

class CameraStopped extends CameraEvent {}

class CameraCaptured extends CameraEvent {}

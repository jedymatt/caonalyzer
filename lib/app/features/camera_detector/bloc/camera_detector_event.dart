part of 'camera_detector_bloc.dart';

@immutable
abstract class CameraDetectorEvent {}

class CameraDetectorStarted extends CameraDetectorEvent {
  final CameraImage image;
  CameraDetectorStarted({required this.image});
}

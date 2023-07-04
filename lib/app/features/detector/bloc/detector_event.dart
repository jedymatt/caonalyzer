part of 'detector_bloc.dart';

@immutable
abstract class DetectorEvent {}

class DetectorStarted extends DetectorEvent {
  final CameraImage image;
  DetectorStarted({required this.image});
}

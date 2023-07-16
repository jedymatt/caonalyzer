part of 'camera_detector_bloc.dart';

@immutable
abstract class CameraDetectorState {
  final List<DetectedObject> detectedObjects;
  const CameraDetectorState({
    required this.detectedObjects,
  });
}

class CameraDetectorInitial extends CameraDetectorState {
  CameraDetectorInitial() : super(detectedObjects: []);
}

class CameraDetectorInProgress extends CameraDetectorState {
  CameraDetectorInProgress() : super(detectedObjects: []);
}

class CameraDetectorSuccess extends CameraDetectorState {
  const CameraDetectorSuccess({required super.detectedObjects});
}

class CameraDetectorFailure extends CameraDetectorState {
  final String message;
  const CameraDetectorFailure({required this.message})
      : super(detectedObjects: const []);
}

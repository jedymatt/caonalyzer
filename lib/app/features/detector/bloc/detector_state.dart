part of 'detector_bloc.dart';

@immutable
abstract class DetectorState {
  final List<DetectedObject> detectedObjects;
  const DetectorState({
    required this.detectedObjects,
  });
}

class DetectorInitial extends DetectorState {
  DetectorInitial() : super(detectedObjects: []);
}

class DetectorInProgress extends DetectorState {
  DetectorInProgress() : super(detectedObjects: []);
}

class DetectorSuccess extends DetectorState {
  const DetectorSuccess({required super.detectedObjects});
}

class DetectorFailure extends DetectorState {
  final String message;
  const DetectorFailure({required this.message})
      : super(detectedObjects: const []);
}

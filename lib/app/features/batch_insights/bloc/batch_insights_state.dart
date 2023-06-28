part of 'batch_insights_bloc.dart';

@immutable
abstract class BatchInsightsState {}

class BatchInsightsInitial extends BatchInsightsState {}

class BatchInsightsInProgress extends BatchInsightsState {}

class BatchInsightsSuccess extends BatchInsightsState {
  final List<List<DetectedObject>> imagesDetectedObjects;
  final int moldsCount;
  final double averageMoldPerImage;
  final double averageOverallConfidence;

  BatchInsightsSuccess({
    required this.imagesDetectedObjects,
    required this.moldsCount,
    required this.averageMoldPerImage,
    required this.averageOverallConfidence,
  });
}

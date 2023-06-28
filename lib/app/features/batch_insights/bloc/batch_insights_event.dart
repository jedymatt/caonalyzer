part of 'batch_insights_bloc.dart';

@immutable
abstract class BatchInsightsEvent {}

class BatchInsightsStarted extends BatchInsightsEvent {
  final List<String> images;
  BatchInsightsStarted({
    required this.images,
  });
}

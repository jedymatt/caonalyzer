part of 'batch_bloc.dart';

@immutable
abstract class BatchEvent {}

class BatchStarted extends BatchEvent {
  final String batchPath;
  BatchStarted({
    required this.batchPath,
  });
}

class BatchImagesFetched extends BatchEvent {
  final String batchPath;

  BatchImagesFetched({required this.batchPath});
}

class BatchImageSelectionToggled extends BatchEvent {
  final int index;

  BatchImageSelectionToggled({required this.index});
}

class BatchImageSelectionEnabled extends BatchEvent {
  final int? startingSelectedIndex;
  BatchImageSelectionEnabled({this.startingSelectedIndex});
}

class BatchImageSelectionDisabled extends BatchEvent {}

class BatchSelectedImagesDeleted extends BatchEvent {}

class BatchAllImagesSelected extends BatchEvent {}

class BatchAllImagesDeselected extends BatchEvent {}

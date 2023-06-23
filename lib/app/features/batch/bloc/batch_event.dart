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

class BatchImagesSelected extends BatchEvent {
  final List<String> selectedImages;

  BatchImagesSelected({required this.selectedImages});
}

class BatchSelectionCanceled extends BatchEvent {}

class BatchImagesDeleted extends BatchEvent {
  final List<String> images;

  BatchImagesDeleted({required this.images});
}

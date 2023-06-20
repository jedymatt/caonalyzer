part of 'batch_bloc.dart';

@immutable
abstract class BatchEvent {}

class BatchFetchImagesEvent extends BatchEvent {
  final String batchPath;

  BatchFetchImagesEvent({required this.batchPath});
}

class BatchSelectMultipleImagesEvent extends BatchEvent {
  final List<String> images;
  final List<String> selectedImages;

  BatchSelectMultipleImagesEvent({required this.images, required this.selectedImages});
}

class BatchCancelSelectionModeEvent extends BatchEvent {
  final List<String> images;

  BatchCancelSelectionModeEvent({required this.images});
}
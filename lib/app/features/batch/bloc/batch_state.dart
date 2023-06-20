part of 'batch_bloc.dart';

@immutable
abstract class BatchState {}

abstract class BatchActionState extends BatchState {}

class BatchInitial extends BatchState {}

class BatchLoadingFetchImages extends BatchState {}

class BatchSuccessfulFetchImages extends BatchState {
  final List<String> images;

  BatchSuccessfulFetchImages({
    required this.images,
  });
}

class BatchSelectionModeState extends BatchState {
  final List<String> images;
  final List<String> selectedImages;

  BatchSelectionModeState({required this.images, required this.selectedImages});
}

class BatchMultiSelectImagesState extends BatchState {
  final List<String> images;
  final List<String> selectedImages;

  BatchMultiSelectImagesState({
    required this.images,
    required this.selectedImages,
  });
}

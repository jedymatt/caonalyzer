part of 'batch_bloc.dart';

@immutable
abstract class BatchState {}

abstract class BatchActionState extends BatchState {}

class BatchInitial extends BatchState {}

class BatchLoading extends BatchState {}

class BatchSuccess extends BatchState {
  final List<String> images;

  BatchSuccess({
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

class BatchDeletingImagesState extends BatchState {}

class BatchNavigateToParentPageActionState extends BatchActionState {}

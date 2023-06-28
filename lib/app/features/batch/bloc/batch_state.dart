part of 'batch_bloc.dart';

@immutable
abstract class BatchState {}

abstract class BatchActionState extends BatchState {}

class BatchInitial extends BatchState {}

class BatchLoading extends BatchState {}

class BatchSuccess extends BatchState {
  final List<String> images;
  final List<String> selectedImages;
  final bool selectionEnabled;

  BatchSuccess({
    required this.images,
    this.selectedImages = const [],
    this.selectionEnabled = false,
  });

  BatchSuccess copyWith({
    List<String>? images,
    List<String>? selectedImages,
    bool? selectionEnabled,
  }) {
    return BatchSuccess(
      images: images ?? this.images,
      selectedImages: selectedImages ?? this.selectedImages,
      selectionEnabled: selectionEnabled ?? this.selectionEnabled,
    );
  }
}

class BatchDeletingImagesState extends BatchState {}

class BatchNavigateToParentPageActionState extends BatchActionState {}

part of 'batch_confirmation_bloc.dart';

@immutable
abstract class BatchConfirmationState {}

abstract class BatchConfirmationActionState extends BatchConfirmationState {}

class BatchConfirmationInitial extends BatchConfirmationState {
  final String? batchPath;
  final List<String> images;
  final int currentIndex;

  BatchConfirmationInitial({
    this.batchPath,
    this.images = const [],
    this.currentIndex = 0,
  });

  BatchConfirmationInitial copyWith({
    String? batchPath,
    List<String>? images,
    int? currentIndex,
  }) {
    return BatchConfirmationInitial(
      batchPath: batchPath ?? this.batchPath,
      images: images ?? this.images,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

class BatchConfirmationLoadingSaveBatchState extends BatchConfirmationState {}

class BatchConfirmationAddImageState extends BatchConfirmationActionState {}

class BatchConfirmationNavigateToBatchPageActionState
    extends BatchConfirmationActionState {
  final String batchPath;

  BatchConfirmationNavigateToBatchPageActionState({required this.batchPath});
}

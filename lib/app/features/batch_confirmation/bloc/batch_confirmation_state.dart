part of 'batch_confirmation_bloc.dart';

@immutable
abstract class BatchConfirmationState {}

abstract class BatchConfirmationActionState extends BatchConfirmationState {}

class BatchConfirmationInitial extends BatchConfirmationState {
  final List<String> images;
  final int currentIndex;
  BatchConfirmationInitial({
    required this.images,
    this.currentIndex = 0,
  });
}

class BatchConfirmationLoadingSaveBatchState extends BatchConfirmationState {}

class BatchConfirmationRetakeImageState extends BatchConfirmationActionState {
  final List<String> currentImages;
  final int selectedIndex;
  BatchConfirmationRetakeImageState({
    required this.currentImages,
    required this.selectedIndex,
  });
}

class BatchConfirmationAddImageState extends BatchConfirmationActionState {}

class BatchConfirmationNavigateToBatchPageActionState
    extends BatchConfirmationActionState {
  final String batchPath;

  BatchConfirmationNavigateToBatchPageActionState({required this.batchPath});
}

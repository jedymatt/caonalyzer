part of 'batch_confirmation_bloc.dart';

@immutable
abstract class BatchConfirmationState {}

abstract class BatchConfirmationActionState extends BatchConfirmationState {}

class BatchConfirmationInitial extends BatchConfirmationState {}

class BatchConfirmationLoadingSaveBatchState extends BatchConfirmationState {}

class BatchConfirmationRetakeImageState extends BatchConfirmationActionState {}

class BatchConfirmationAddImageState extends BatchConfirmationActionState {}


class BatchConfirmationNavigateToBatchPageActionState
    extends BatchConfirmationActionState {
  final String batchPath;

  BatchConfirmationNavigateToBatchPageActionState({required this.batchPath});
}

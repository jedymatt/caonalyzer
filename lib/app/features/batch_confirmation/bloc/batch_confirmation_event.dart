part of 'batch_confirmation_bloc.dart';

@immutable
abstract class BatchConfirmationEvent {}

class BatchConfirmationInitialEvent extends BatchConfirmationEvent {}

class BatchConfirmationRetakeImageEvent extends BatchConfirmationEvent {}

class BatchConfirmationAddImageEvent extends BatchConfirmationEvent {}

class BatchConfirmationSaveBatchEvent extends BatchConfirmationEvent {
  final String batchPath;
  final List<String> images;
  BatchConfirmationSaveBatchEvent({required this.batchPath, required this.images});
}
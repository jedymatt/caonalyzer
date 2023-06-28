part of 'batch_confirmation_bloc.dart';

@immutable
abstract class BatchConfirmationEvent {}

class BatchConfirmationStarted extends BatchConfirmationEvent {
  final String? batchPath;
  BatchConfirmationStarted({this.batchPath});
}

class BatchConfirmationImageRetaked extends BatchConfirmationEvent {
  final String imagePath;
  BatchConfirmationImageRetaked({required this.imagePath});
}

class BatchConfirmationImagePageChanged extends BatchConfirmationEvent {
  final int index;

  BatchConfirmationImagePageChanged({required this.index});
}

class BatchConfirmationImageAdded extends BatchConfirmationEvent {
  final String imagePath;
  BatchConfirmationImageAdded({
    required this.imagePath,
  });
}

class BatchConfirmationBatchSaved extends BatchConfirmationEvent {}

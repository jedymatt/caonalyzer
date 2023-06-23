part of 'batch_confirmation_bloc.dart';

@immutable
abstract class BatchConfirmationEvent {}

class BatchConfirmationStarted extends BatchConfirmationEvent {
  final List<String> images;
  final int currentIndex;
  BatchConfirmationStarted({required this.images, this.currentIndex = 0});
}

class BatchConfirmationImageRetaked extends BatchConfirmationEvent {
  final String imagePath;
  BatchConfirmationImageRetaked({required this.imagePath});
}

class BatchConfirmationImagePageChanged extends BatchConfirmationEvent {
  final int index;

  BatchConfirmationImagePageChanged({required this.index});
}

class BatchConfirmationImageAdded extends BatchConfirmationEvent {}

class BatchConfirmationBatchSaved extends BatchConfirmationEvent {}

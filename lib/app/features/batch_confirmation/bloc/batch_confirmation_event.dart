part of 'batch_confirmation_bloc.dart';

@immutable
abstract class BatchConfirmationEvent {}

class BatchConfirmationInitialEvent extends BatchConfirmationEvent {
  final List<String> images;
  final int currentIndex;
  BatchConfirmationInitialEvent({required this.images, this.currentIndex = 0});
}

class BatchConfirmationRetakeImageEvent extends BatchConfirmationEvent {
  final String retakedImagePath;
  final int toRetakeImageIndex;
  final List<String> images;
  BatchConfirmationRetakeImageEvent({
    required this.retakedImagePath,
    required this.toRetakeImageIndex,
    required this.images,
  });
}

class BatchConfirmationChangeImagePageEvent extends BatchConfirmationEvent {
  final int index;
  final List<String> images;
  BatchConfirmationChangeImagePageEvent({
    required this.index,
    required this.images,
  });
}

class BatchConfirmationAddImageEvent extends BatchConfirmationEvent {}

class BatchConfirmationSaveBatchEvent extends BatchConfirmationEvent {
  final String batchPath;
  final List<String> images;
  BatchConfirmationSaveBatchEvent(
      {required this.batchPath, required this.images});
}

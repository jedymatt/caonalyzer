part of 'gallery_bloc.dart';

@immutable
abstract class GalleryEvent {}

class GalleryInitialEvent extends GalleryEvent {}

class GalleryRefreshImagesEvent extends GalleryEvent {
  final List<Batch> placeholderBatches;

  GalleryRefreshImagesEvent({this.placeholderBatches = const []});
}

class GalleryNavigateToBatchEvent extends GalleryEvent {
  final Batch batch;

  GalleryNavigateToBatchEvent({required this.batch});
}

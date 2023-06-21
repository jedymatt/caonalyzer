part of 'gallery_bloc.dart';

@immutable
abstract class GalleryEvent {}

class GalleryInitialEvent extends GalleryEvent {}

class GalleryFetchImagesEvent extends GalleryEvent {}

class GalleryNavigateToBatchEvent extends GalleryEvent {
  final Batch batch;

  GalleryNavigateToBatchEvent({required this.batch});
}

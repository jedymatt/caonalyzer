part of 'gallery_bloc.dart';

@immutable
abstract class GalleryState {}

abstract class GalleryActionState extends GalleryState {}

class GalleryInitial extends GalleryState {}

class GalleryInProgress extends GalleryState {}

class GallerySuccess extends GalleryState {
  final List<Batch> batches;

  GallerySuccess({required this.batches});
}

class GalleryRefreshInProgress extends GalleryState {}

class GalleryRefreshSuccess extends GalleryState {}
